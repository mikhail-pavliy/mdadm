 # Собиравем  RAID/10
 
 sudo lshw -short | grep disk
 
 3ануляем суперблоки
 
 mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
 
 Создаем Raid следующей командой
 
 mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e,f}
 
 Проверим что RAID собрался
 
 cat /proc/mdstat
 
 Должно выйти следующее
 
 Personalities : [raid10]
 
md0 : active raid10 sde[4] sdd[2] sdc[1] sdb[0]

610304 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]

Просмотрим все диски:

fdisk -l

Создем раздел GPT на неразмеченном диске /dev/sdb

gdisk /dev/sdb

n

fd00

w

копируем таблицу разделов на другие жесткие диски /dev/sdc, /dev/sdd, /dev/sde:

sudo sgdisk -G /dev/sdc

sudo sgdisk -R /dev/sdd /dev/sdb

sudo sgdisk -G /dev/sdd

sudo sgdisk -R /dev/sde /dev/sdb

sudo sgdisk -G /dev/sde

отформатируем дисковый массив:

sudo mkfs.ext4 /dev/md0

создаём файл mdadm.conf

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf

и записываем в него информацию

sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>mdadm.conf

проверем запись

nano /etc/mdadm/mdadm.conf

редактируем файл fstab для монтирования массива при запуске системы:

nano /etc/fstab

и вносим следующие данные

/dev/md0 /mnt/md0          ext4    defaults        0       4

