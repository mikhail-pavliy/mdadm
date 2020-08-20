mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
# Log in as a super user
sudo su
# Create RAID/10
sudo lshw -short | grep disk
# Zeroing superblocks
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
# Create Raid following command
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
# Verify that the RAID is assembled
cat /proc/mdstat
# The following should come out
#Personalities : [raid10]
#md0 : active raid10 sde[4] sdd[2] sdc[1] sdb[0]
#610304 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
# Let's look at all disks
# create mdadm.conf file
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
# and write information into it
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>mdadm.conf
fdisk -l
# Create a GPT partition on an unallocated disk /dev/sdb
gdisk /dev/sdb
n
fd00
w
# copy the partition table to other hard drives /dev/sdc, /dev/sdd, /dev/sde:
sgdisk -G /dev/sdc
sgdisk -R /dev/sdd /dev/sdb
sgdisk -G /dev/sdd
sgdisk -R /dev/sde /dev/sdb
sgdisk -G /dev/sde
# format the disk array
sudo mkfs.ext4 /dev/md0
# edit the fstab file to mount the array at system startup
if ! grep -q 'md0' /etc/fstab ; then
    echo '# Raid10' >> /etc/fstab
    echo '/dev/md0 /mnt/md0 ext4 defaults 0 4' >> /etc/fstab
fi
# restart the system
shutdown -r now
