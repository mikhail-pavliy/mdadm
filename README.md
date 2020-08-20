	# Log in as a super user
```bash
sudo su
```
	# Create RAID/10
```bash
sudo lshw -short | grep disk
```
	# Zeroing superblocks
```bash
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
```
	# Create Raid following command
```bash
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
```
	# Verify that the RAID is assembled
```bash
cat /proc/mdstat
```
	# The following should come out
 # Personalities : [raid10]
 # md0 : active raid10 sde[4] sdd[2] sdc[1] sdb[0]
 # 610304 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
	# Let's look at all disks
	# create mdadm.conf file
```bash
mkdir /etc/mdadm
```
```bash
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf```
	# and write information into it
```bash
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>mdadm.conf
```
```bash
fdisk -l
```
	# Create a GPT partition on an unallocated disk /dev/sdb
```bash
gdisk /dev/sdb
```
```bash
n
```
```bash
fd00
```
```bash
w
```
	# copy the partition table to other hard drives /dev/sdc, /dev/sdd, /dev/sde:
```bash
sgdisk -G /dev/sdc
sgdisk -R /dev/sdd /dev/sdb
sgdisk -G /dev/sdd
sgdisk -R /dev/sde /dev/sdb
sgdisk -G /dev/sde
```
	# format the disk array
```bash
sudo mkfs.ext4 /dev/md0
```
	# edit the fstab file to mount the array at system startup
```bash
if ! grep -q 'md0' /etc/fstab ; then
    echo '# Raid10' >> /etc/fstab
    echo '/dev/md0 /mnt/md0 ext4 defaults 0 4' >> /etc/fstab
fi
```
	# restart the system
```bash
shutdown -r now
```
