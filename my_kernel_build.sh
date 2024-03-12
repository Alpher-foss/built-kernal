#!/bin/bash

# Script name (modify as desired)
SCRIPT_NAME="my_kernel_build.sh"

# Get kernel source URL from user
echo "Enter the URL of the kernel source (e.g., https://github.com/vendor/kernel_source.zip):"
read -r KERNEL_URL

# Update package lists and install dependencies
echo "** Updating package lists and installing dependencies..."
sudo add-apt-repository universe &> /dev/null || { echo "Failed adding repository. Check internet connection or permissions"; exit 1; }
sudo apt update &> /dev/null || { echo "Failed updating package lists. Check internet connection"; exit 1; }
sudo apt install -y build-essential gcc libc6-dev binutils libncurses-dev flex bison bc libssl-dev libncurses5-dev &> /dev/null || { echo "Failed installing dependencies. Check package names"; exit 1; }

# Download Kernel Source
echo "** Downloading kernel source from $KERNEL_URL..."
wget -O kernel.zip "$KERNEL_URL" || { echo "Failed downloading kernel source. Check URL and internet connection"; exit 1; }

# Extract the zip file and rename the folder as "kernel"
unzip kernel.zip -d kernel > /dev/null || { echo "Failed to extract kernel source. Check the downloaded file"; exit 1; }

# Remove the temporary zip file
rm kernel.zip

# Download Toolchain
TOOLCHAIN_URL="https://github.com/Alpher-foss/toolchains/archive/refs/heads/master.zip"

echo "** Downloading toolchain from $TOOLCHAIN_URL..."
wget -O toolchain_temp.zip "$TOOLCHAIN_URL" || { echo "Failed downloading toolchain. Check URL and internet connection"; exit 1; }

# Extract the zip file
unzip toolchain_temp.zip > /dev/null || { echo "Failed to extract toolchain. Check the downloaded file"; exit 1; }

# Remove the temporary zip file
rm toolchain_temp.zip


# Move extracted toolchain folder
mv  toolchains-master/ /opt/toolchains

# Generate build.sh script
BUILD_SCRIPT="build.sh"

# Prompt the user for the codename
read -p "Enter the codename: " CODENAME

# Append "_defconfig" to the codename
CONFIG_NAME="${CODENAME}_defconfig"

echo "#!/bin/bash" > "$BUILD_SCRIPT"
echo "config=$CONFIG_NAME" >> "$BUILD_SCRIPT"
echo "export PATH=\"/opt/toolchains/clang-r428724/bin:/opt/toolchains/aarch64-linux-android-4.9/bin:/opt/toolchains/arm-linux-androideabi-4.9/bin:\$PATH\"" >> "$BUILD_SCRIPT"
echo "export ARCH=arm64" >> "$BUILD_SCRIPT"
echo "export CROSS_COMPILE=aarch64-linux-android-" >> "$BUILD_SCRIPT"
echo "export CROSS_COMPILE_ARM32=arm-linux-androideabi-" >> "$BUILD_SCRIPT"
echo "export CROSS_TRIPLE=aarch64-linux-gnu-" >> "$BUILD_SCRIPT"

# Move the generated build.sh script to the kernel folder
mv "$BUILD_SCRIPT" "kernel/"

# Set execute permissions for the build.sh script
chmod +x "kernel/$BUILD_SCRIPT"

# Change directory to the kernel folder

cd kernel/

# mv build.sh */

mv build.sh */

# Run the build.sh script

source build.sh
export CLANG_TRIPLE=aarch64-linux-gnu-

# Create output directory

mkdir output

# Build the kernel

make -j4 CC=clang O=output $config

# edit kernal

make -j4 CC=clang O=output $config menuconfig

# compile kernal

make -j4 CC=clang O=output
