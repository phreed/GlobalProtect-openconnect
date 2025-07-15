#!/usr/bin/env python3
"""
gpclientw.py - Comprehensive GlobalProtect OpenConnect Client Wrapper

A Python wrapper for gpclient that handles version overrides, HIP reports,
and different connection modes for Vanderbilt VPN.

Features:
- Automatic version override (fixes "6.1.4 or above" errors)
- HIP report support for compliance
- Multiple connection modes (user, root, userspace)
- Dynamic gateway selection
- Comprehensive error handling
- Detailed logging and status reporting

Author: Generated from gpoc project scripts
License: Same as parent project
"""

import argparse
import json
import logging
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'  # No Color

    @classmethod
    def disable(cls):
        """Disable colors for non-terminal output."""
        cls.RED = cls.GREEN = cls.YELLOW = cls.BLUE = cls.CYAN = cls.BOLD = cls.NC = ''


class VPNError(Exception):
    """Custom exception for VPN-related errors."""
    pass


class GlobalProtectWrapper:
    """Main wrapper class for GlobalProtect client operations."""

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.script_dir = Path(__file__).parent.absolute()
        self.gpclient = self.script_dir / "target" / "release" / "gpclient"
        self.gpauth = self.script_dir / "target" / "release" / "gpauth"
        self.override_lib = self.script_dir / "gp_version_override.so"
        self.cookie_file = None
        self.process = None

        # Setup logging
        log_level = logging.DEBUG if args.verbose else logging.INFO
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%H:%M:%S'
        )
        self.logger = logging.getLogger(__name__)

        # Disable colors if not in terminal or if requested
        if not sys.stdout.isatty() or args.no_color:
            Colors.disable()

    def print_banner(self):
        """Print application banner."""
        print(f"\n{Colors.BLUE}{'='*60}{Colors.NC}")
        print(f"{Colors.BOLD}GlobalProtect OpenConnect Client Wrapper{Colors.NC}")
        print(f"{Colors.BLUE}{'='*60}{Colors.NC}")
        print(f"Server: {Colors.CYAN}{self.args.server}{Colors.NC}")
        print(f"Mode: {Colors.CYAN}{self.args.mode}{Colors.NC}")
        print(f"Client Version: {Colors.CYAN}{self.args.client_version}{Colors.NC}")
        if self.args.gateway:
            print(f"Gateway: {Colors.CYAN}{self.args.gateway}{Colors.NC}")
        print(f"HIP Support: {Colors.CYAN}{'Enabled' if self.args.hip else 'Disabled'}{Colors.NC}")
        print(f"Version Override: {Colors.GREEN}Active{Colors.NC}")
        print()

    def check_dependencies(self):
        """Check if required files and dependencies exist."""
        self.logger.info("Checking dependencies...")

        missing = []

        if not self.gpclient.exists():
            missing.append(f"gpclient not found at {self.gpclient}")

        if not self.gpauth.exists() and self.args.mode == 'root':
            missing.append(f"gpauth not found at {self.gpauth}")

        if not self.override_lib.exists():
            missing.append(f"Version override library not found at {self.override_lib}")

        if self.args.hip:
            hip_script = self._find_hip_script()
            if not hip_script:
                missing.append("HIP report script not found")

        if missing:
            print(f"{Colors.RED}Missing dependencies:{Colors.NC}")
            for item in missing:
                print(f"  ❌ {item}")
            print(f"\n{Colors.YELLOW}Please run the following to fix:{Colors.NC}")
            print(f"  pixi run develop-cli")
            print(f"  pixi run create-gp-version-override")
            raise VPNError("Missing required dependencies")

        print(f"{Colors.GREEN}✅ All dependencies found{Colors.NC}")

    def _find_hip_script(self) -> Optional[str]:
        """Find the HIP report script."""
        locations = [
            "/usr/lib/x86_64-linux-gnu/openconnect/hipreport.sh",
            "/usr/lib/aarch64-linux-gnu/openconnect/hipreport.sh",
            "/usr/lib/openconnect/hipreport.sh",
            "/usr/libexec/openconnect/hipreport.sh",
            "/opt/homebrew/opt/openconnect/libexec/openconnect/hipreport.sh",
        ]

        for location in locations:
            if os.path.isfile(location) and os.access(location, os.X_OK):
                return location
        return None

    def setup_environment(self):
        """Setup environment variables for version override."""
        os.environ['GP_APP_VERSION'] = self.args.client_version
        os.environ['LD_PRELOAD'] = str(self.override_lib)
        self.logger.debug(f"Set GP_APP_VERSION={self.args.client_version}")
        self.logger.debug(f"Set LD_PRELOAD={self.override_lib}")

    def build_base_command(self, binary: Path) -> List[str]:
        """Build base command with common arguments."""
        cmd = [str(binary)]

        if self.args.fix_openssl:
            cmd.append('--fix-openssl')

        if self.args.ignore_tls_errors:
            cmd.append('--ignore-tls-errors')

        if self.args.verbose:
            cmd.append('--verbose')

        return cmd

    def authenticate(self) -> str:
        """Perform authentication and return cookie file path."""
        print(f"{Colors.YELLOW}Step 1: Performing authentication...{Colors.NC}")

        cmd = self.build_base_command(self.gpauth)
        cmd.extend([
            '--client-version', self.args.client_version,
            self.args.server
        ])

        # Create temporary cookie file
        fd, cookie_file = tempfile.mkstemp(suffix='.json', prefix='vpn-cookie-')
        os.close(fd)
        self.cookie_file = cookie_file

        try:
            self.logger.info(f"Running authentication: {' '.join(cmd)}")
            with open(cookie_file, 'w') as f:
                result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)

            if result.returncode != 0:
                raise VPNError(f"Authentication failed: {result.stderr}")

            # Verify cookie file has content
            if os.path.getsize(cookie_file) == 0:
                raise VPNError("Authentication cookie is empty")

            print(f"{Colors.GREEN}✅ Authentication successful{Colors.NC}")
            return cookie_file

        except Exception as e:
            if os.path.exists(cookie_file):
                os.unlink(cookie_file)
            raise VPNError(f"Authentication failed: {e}")

    def build_connect_command(self, use_cookie: bool = False) -> List[str]:
        """Build the gpclient connect command."""
        cmd = self.build_base_command(self.gpclient)
        cmd.extend(['connect', self.args.server])

        cmd.extend(['--client-version', self.args.client_version])

        if self.args.gateway:
            cmd.extend(['--gateway', self.args.gateway])

        if self.args.hip:
            cmd.append('--hip')

        if self.args.interface:
            cmd.extend(['--interface', self.args.interface])

        if self.args.script:
            cmd.extend(['--script', self.args.script])

        if self.args.mtu:
            cmd.extend(['--mtu', str(self.args.mtu)])

        if self.args.disable_ipv6:
            cmd.append('--disable-ipv6')

        if self.args.no_dtls:
            cmd.append('--no-dtls')

        if use_cookie:
            cmd.append('--cookie-on-stdin')

        # Add any extra arguments
        if hasattr(self.args, 'extra_args') and self.args.extra_args:
            cmd.extend(self.args.extra_args)

        return cmd

    def connect_user_mode(self):
        """Connect in user mode (no root required, limited functionality)."""
        print(f"{Colors.YELLOW}Connecting in user mode...{Colors.NC}")
        print(f"{Colors.YELLOW}Note: This mode has limitations - no system routing changes{Colors.NC}")

        cmd = self.build_connect_command()
        self.logger.info(f"Running: {' '.join(cmd)}")

        try:
            self.process = subprocess.Popen(cmd)
            self._handle_connection_process()
        except KeyboardInterrupt:
            print(f"\n{Colors.YELLOW}Connection interrupted by user{Colors.NC}")
        except Exception as e:
            raise VPNError(f"Connection failed: {e}")

    def connect_root_mode(self):
        """Connect in root mode (full functionality)."""
        print(f"{Colors.YELLOW}Connecting in root mode for full VPN functionality...{Colors.NC}")

        # Check if already root
        if os.geteuid() == 0:
            raise VPNError("Do not run this script as root directly! Use sudo when prompted.")

        # Step 1: Authenticate as user
        cookie_file = self.authenticate()

        # Step 2: Connect as root using cookie
        print(f"{Colors.YELLOW}Step 2: Establishing VPN tunnel as root{Colors.NC}")
        print(f"{Colors.YELLOW}You will be prompted for your sudo password...{Colors.NC}\n")

        cmd = ['sudo', '-E'] + [f'GP_APP_VERSION={self.args.client_version}'] + \
              [f'LD_PRELOAD={self.override_lib}'] + self.build_connect_command(use_cookie=True)

        self.logger.info(f"Running: {' '.join(cmd)}")

        try:
            with open(cookie_file, 'r') as f:
                self.process = subprocess.Popen(cmd, stdin=f)
            self._handle_connection_process()
        except KeyboardInterrupt:
            print(f"\n{Colors.YELLOW}Connection interrupted by user{Colors.NC}")
        except Exception as e:
            raise VPNError(f"Root connection failed: {e}")

    def connect_userspace_mode(self):
        """Connect in userspace mode (alternative approach)."""
        print(f"{Colors.YELLOW}Connecting in userspace mode...{Colors.NC}")
        print(f"{Colors.YELLOW}Note: This is an experimental mode with limited functionality{Colors.NC}")

        cmd = self.build_connect_command()
        self.logger.info(f"Running: {' '.join(cmd)}")

        print(f"\n{Colors.CYAN}Userspace VPN Notes:{Colors.NC}")
        print("• This mode may not provide full system-wide VPN access")
        print("• For applications to use the VPN, they may need proxy configuration")
        print("• For full functionality, use root mode")
        print()

        try:
            self.process = subprocess.Popen(cmd)
            self._handle_connection_process()
        except KeyboardInterrupt:
            print(f"\n{Colors.YELLOW}Connection interrupted by user{Colors.NC}")
        except Exception as e:
            raise VPNError(f"Userspace connection failed: {e}")

    def _handle_connection_process(self):
        """Handle the connection process and provide status updates."""
        if not self.process:
            return

        print(f"{Colors.GREEN}VPN connection process started (PID: {self.process.pid}){Colors.NC}")

        if self.args.mode == 'root':
            print(f"\n{Colors.CYAN}Connection Status:{Colors.NC}")
            print("• VPN tunnel should be establishing...")
            print("• Check network interfaces: ip addr show")
            print("• Check routing: ip route show")
            print("• Test connectivity: curl https://face-git.isis.vanderbilt.edu")
            print(f"\n{Colors.YELLOW}To disconnect: sudo pkill -f gpclient{Colors.NC}")
        else:
            print(f"\n{Colors.YELLOW}Note: Running in non-root mode may have limited functionality{Colors.NC}")

        print(f"\n{Colors.CYAN}Press Ctrl+C to disconnect{Colors.NC}")

        try:
            self.process.wait()
        except KeyboardInterrupt:
            print(f"\n{Colors.YELLOW}Terminating VPN connection...{Colors.NC}")
            self._cleanup_process()

    def _cleanup_process(self):
        """Clean up the VPN process."""
        if self.process:
            try:
                self.process.terminate()
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()
            except Exception:
                pass

    def cleanup(self):
        """Perform cleanup operations."""
        if self.cookie_file and os.path.exists(self.cookie_file):
            try:
                os.unlink(self.cookie_file)
                self.logger.debug(f"Cleaned up cookie file: {self.cookie_file}")
            except Exception:
                pass

    def show_status(self):
        """Show current VPN status."""
        print(f"{Colors.BOLD}VPN Status Check{Colors.NC}")
        print("="*50)

        # Check for running gpclient processes
        try:
            result = subprocess.run(['pgrep', '-f', 'gpclient'], capture_output=True, text=True)
            if result.returncode == 0:
                pids = result.stdout.strip().split('\n')
                print(f"{Colors.GREEN}✅ gpclient processes running: {', '.join(pids)}{Colors.NC}")
            else:
                print(f"{Colors.RED}❌ No gpclient processes found{Colors.NC}")
        except Exception:
            print(f"{Colors.YELLOW}⚠️  Could not check process status{Colors.NC}")

        # Check network interfaces
        try:
            result = subprocess.run(['ip', 'addr', 'show'], capture_output=True, text=True)
            if 'tun0' in result.stdout:
                print(f"{Colors.GREEN}✅ VPN interface (tun0) detected{Colors.NC}")
            else:
                print(f"{Colors.RED}❌ No VPN interface found{Colors.NC}")
        except Exception:
            print(f"{Colors.YELLOW}⚠️  Could not check network interfaces{Colors.NC}")

        # Test internal connectivity
        print(f"\n{Colors.CYAN}Testing Vanderbilt connectivity...{Colors.NC}")
        try:
            result = subprocess.run([
                'curl', '-I', '--connect-timeout', '5',
                'https://face-git.isis.vanderbilt.edu'
            ], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"{Colors.GREEN}✅ Can access internal Vanderbilt resources{Colors.NC}")
            else:
                print(f"{Colors.RED}❌ Cannot access internal Vanderbilt resources{Colors.NC}")
        except Exception:
            print(f"{Colors.YELLOW}⚠️  Could not test connectivity{Colors.NC}")

    def disconnect(self):
        """Disconnect active VPN connections."""
        print(f"{Colors.YELLOW}Disconnecting VPN...{Colors.NC}")

        try:
            # Try to find and kill gpclient processes
            result = subprocess.run(['pgrep', '-f', 'gpclient'], capture_output=True, text=True)
            if result.returncode == 0:
                pids = result.stdout.strip().split('\n')
                for pid in pids:
                    try:
                        subprocess.run(['sudo', 'kill', pid], check=True)
                        print(f"{Colors.GREEN}✅ Terminated process {pid}{Colors.NC}")
                    except subprocess.CalledProcessError:
                        print(f"{Colors.RED}❌ Failed to terminate process {pid}{Colors.NC}")
            else:
                print(f"{Colors.YELLOW}No gpclient processes found{Colors.NC}")
        except Exception as e:
            print(f"{Colors.RED}Error during disconnection: {e}{Colors.NC}")

    def connect(self):
        """Main connection method - routes to appropriate mode."""
        try:
            self.print_banner()
            self.check_dependencies()
            self.setup_environment()

            if self.args.mode == 'user':
                self.connect_user_mode()
            elif self.args.mode == 'root':
                self.connect_root_mode()
            elif self.args.mode == 'userspace':
                self.connect_userspace_mode()
            else:
                raise VPNError(f"Unknown connection mode: {self.args.mode}")

        except VPNError as e:
            print(f"{Colors.RED}Error: {e}{Colors.NC}")
            return 1
        except KeyboardInterrupt:
            print(f"\n{Colors.YELLOW}Operation cancelled by user{Colors.NC}")
            return 1
        except Exception as e:
            print(f"{Colors.RED}Unexpected error: {e}{Colors.NC}")
            return 1
        finally:
            self.cleanup()

        return 0


def create_parser() -> argparse.ArgumentParser:
    """Create command line argument parser."""
    parser = argparse.ArgumentParser(
        description='GlobalProtect OpenConnect Client Wrapper',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Connect with automatic gateway selection (root mode)
  %(prog)s connect.vanderbilt.edu

  # Connect to specific gateway in user mode
  %(prog)s connect.vanderbilt.edu -g "US South" -m user

  # Connect with HIP support and custom version
  %(prog)s connect.vanderbilt.edu --hip --client-version 6.3.3

  # Show current VPN status
  %(prog)s --status

  # Disconnect active VPN
  %(prog)s --disconnect

Connection Modes:
  user      - No root required, limited functionality
  root      - Full VPN functionality (default, requires sudo)
  userspace - Alternative approach, experimental
        """
    )

    # Main commands
    group = parser.add_mutually_exclusive_group()
    group.add_argument('server', nargs='?', help='VPN server to connect to (e.g., connect.vanderbilt.edu)')
    group.add_argument('--status', action='store_true', help='Show current VPN status')
    group.add_argument('--disconnect', action='store_true', help='Disconnect active VPN connections')

    # Connection options
    parser.add_argument('-m', '--mode', choices=['user', 'root', 'userspace'],
                       default='root', help='Connection mode (default: root)')
    parser.add_argument('-g', '--gateway', help='Specific gateway to connect to')
    parser.add_argument('--client-version', default='6.3.0',
                       help='GlobalProtect client version to report (default: 6.3.0)')

    # Features
    parser.add_argument('--hip', action='store_true',
                       help='Enable HIP (Host Integrity Protection) reporting')
    parser.add_argument('--fix-openssl', action='store_true', default=True,
                       help='Fix OpenSSL legacy renegotiation issues (default: enabled)')
    parser.add_argument('--ignore-tls-errors', action='store_true', default=True,
                       help='Ignore TLS certificate errors (default: enabled)')

    # Network options
    parser.add_argument('--interface', help='VPN interface name')
    parser.add_argument('--script', help='VPNC script path')
    parser.add_argument('--mtu', type=int, help='MTU size')
    parser.add_argument('--disable-ipv6', action='store_true', help='Disable IPv6')
    parser.add_argument('--no-dtls', action='store_true', help='Disable DTLS')

    # Output options
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--no-color', action='store_true', help='Disable colored output')

    return parser


def main():
    """Main entry point."""
    parser = create_parser()
    args = parser.parse_args()

    # Handle special commands
    if args.status:
        wrapper = GlobalProtectWrapper(args)
        wrapper.show_status()
        return 0

    if args.disconnect:
        wrapper = GlobalProtectWrapper(args)
        wrapper.disconnect()
        return 0

    # Require server for connection
    if not args.server:
        parser.error("Server is required for connection. Use --status or --disconnect for other operations.")

    # Create wrapper and connect
    wrapper = GlobalProtectWrapper(args)
    return wrapper.connect()


if __name__ == '__main__':
    sys.exit(main())
