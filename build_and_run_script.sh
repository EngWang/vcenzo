#!/bin/bash

# Script thiết lập và sử dụng Security Tools Container
# Author: Security Tools Setup
# Usage: ./setup.sh [command]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Kiểm tra Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker chưa được cài đặt!"
        echo "Cài đặt Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose chưa được cài đặt!"
        echo "Cài đặt Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Docker và Docker Compose đã sẵn sàng"
}

# Build Docker image
build_image() {
    print_header "Building Security Tools Container"
    print_info "Quá trình này có thể mất 15-30 phút..."
    
    docker-compose build --no-cache
    
    print_success "Build hoàn tất!"
}

# Start container
start_container() {
    print_header "Starting Security Tools Container"
    
    docker-compose up -d
    
    print_success "Container đã khởi động!"
    print_info "Sử dụng './setup.sh shell' để truy cập container"
}

# Stop container
stop_container() {
    print_header "Stopping Security Tools Container"
    
    docker-compose down
    
    print_success "Container đã dừng!"
}

# Shell access
shell_access() {
    print_header "Accessing Container Shell"
    
    docker exec -it security-pentest /bin/bash
}

# Test all tools
test_tools() {
    print_header "Testing All Tools"
    
    docker exec security-pentest bash -c '
    echo "==================================="
    echo "Testing Installed Tools"
    echo "==================================="
    
    echo "1. Testing Nmap..."
    nmap --version | head -1 && echo "✓ Nmap OK" || echo "✗ Nmap FAILED"
    
    echo ""
    echo "2. Testing Nuclei..."
    nuclei -version 2>&1 | head -1 && echo "✓ Nuclei OK" || echo "✗ Nuclei FAILED"
    
    echo ""
    echo "3. Testing Metasploit..."
    msfconsole --version && echo "✓ Metasploit OK" || echo "✗ Metasploit FAILED"
    
    echo ""
    echo "4. Testing Amass..."
    amass --version && echo "✓ Amass OK" || echo "✗ Amass FAILED"
    
    echo ""
    echo "5. Testing Ffuf..."
    ffuf -V && echo "✓ Ffuf OK" || echo "✗ Ffuf FAILED"
    
    echo ""
    echo "6. Testing Masscan..."
    masscan --version | head -1 && echo "✓ Masscan OK" || echo "✗ Masscan FAILED"
    
    echo ""
    echo "7. Testing Spiderfoot..."
    test -d /opt/tools/spiderfoot && echo "✓ Spiderfoot OK" || echo "✗ Spiderfoot FAILED"
    
    echo ""
    echo "8. Testing Osmedeus..."
    osmedeus version 2>&1 || echo "✓ Osmedeus OK"
    
    echo ""
    echo "9. Testing OpenVAS..."
    which gvm && echo "✓ OpenVAS/GVM OK" || echo "✗ OpenVAS FAILED"
    
    echo ""
    echo "10. Testing ZAP..."
    zap.sh -version 2>&1 | head -1 && echo "✓ ZAP OK" || echo "✗ ZAP FAILED"
    
    echo ""
    echo "==================================="
    echo "Additional Tools:"
    echo "==================================="
    
    which subfinder && echo "✓ Subfinder" || echo "✗ Subfinder"
    which httpx && echo "✓ Httpx" || echo "✗ Httpx"
    which katana && echo "✓ Katana" || echo "✗ Katana"
    which gobuster && echo "✓ Gobuster" || echo "✗ Gobuster"
    which nikto && echo "✓ Nikto" || echo "✗ Nikto"
    which sqlmap && echo "✓ SQLMap" || echo "✗ SQLMap"
    
    echo ""
    echo "==================================="
    echo "Test completed!"
    echo "==================================="
    '
}

# Run specific tool
run_tool() {
    local tool=$1
    shift
    
    print_info "Running $tool..."
    docker exec -it security-pentest $tool "$@"
}

# Show logs
show_logs() {
    docker-compose logs -f
}

# Cleanup
cleanup() {
    print_header "Cleaning Up"
    
    print_info "Stopping container..."
    docker-compose down
    
    read -p "Xóa Docker image? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rmi $(docker images | grep security-pentest | awk '{print $3}')
        print_success "Image đã xóa!"
    fi
    
    read -p "Xóa volumes? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume rm $(docker volume ls | grep pentest | awk '{print $2}')
        print_success "Volumes đã xóa!"
    fi
}

# Quick scan example
quick_scan() {
    local target=$1
    
    if [ -z "$target" ]; then
        print_error "Vui lòng cung cấp target!"
        echo "Usage: ./setup.sh scan <target>"
        exit 1
    fi
    
    print_header "Running Quick Scan on $target"
    
    docker exec security-pentest bash -c "
    mkdir -p /results/$target
    cd /results/$target
    
    echo '[*] Running Nmap scan...'
    nmap -sV -sC -oN nmap_scan.txt $target
    
    echo '[*] Running Nuclei scan...'
    echo $target | nuclei -o nuclei_scan.txt
    
    echo '[*] Running Nikto scan...'
    nikto -h $target -o nikto_scan.txt
    
    echo '[*] Scan completed! Results saved in /results/$target'
    ls -lh /results/$target
    "
    
    print_success "Scan hoàn tất! Kết quả lưu tại ./results/$target"
}

# Main menu
show_menu() {
    print_header "Security Tools Container - Setup Menu"
    echo "1. Build container"
    echo "2. Start container"
    echo "3. Stop container"
    echo "4. Access shell"
    echo "5. Test all tools"
    echo "6. Run quick scan"
    echo "7. Show logs"
    echo "8. Cleanup"
    echo "9. Exit"
    echo ""
    read -p "Chọn option [1-9]: " option
    
    case $option in
        1) build_image ;;
        2) start_container ;;
        3) stop_container ;;
        4) shell_access ;;
        5) test_tools ;;
        6) 
            read -p "Nhập target (IP/domain): " target
            quick_scan "$target"
            ;;
        7) show_logs ;;
        8) cleanup ;;
        9) exit 0 ;;
        *) print_error "Invalid option!" ;;
    esac
}

# Main
main() {
    check_docker
    
    if [ $# -eq 0 ]; then
        show_menu
    else
        case $1 in
            build) build_image ;;
            start) start_container ;;
            stop) stop_container ;;
            shell) shell_access ;;
            test) test_tools ;;
            scan) quick_scan "$2" ;;
            logs) show_logs ;;
            cleanup) cleanup ;;
            run) shift; run_tool "$@" ;;
            *) 
                echo "Usage: $0 {build|start|stop|shell|test|scan|logs|cleanup|run}"
                exit 1
                ;;
        esac
    fi
}

main "$@"
