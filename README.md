# ssdz - Sarah's Sequential Disk Zapper
 
Tool to zap multiple sequential disks (clear MBR & GPT)  
Useful for preparing a large amount of disks for zfs use.

**Requirements**:  sgdisk

**Arguments**:  
  -h, --help    &emsp;&emsp;Display this message  
  -n, --number  &ensp;Number of drives to process (required)  
  -d, --drive   &emsp;&emsp;Starting drive (required)  
  -f, --force   &emsp;&emsp;Skip confirmation  

**Limitations**:  
  Must start on one of first 26 disks /dev/sda - /dev/sdz  
  Usable up to /dev/sdaz  
  *will try to accommodate 26 more drives & starting on drive 27-52 in next version*

**Examples**:  
  ssdz -h  
  ssdz -n 12 -d /dev/sdc  
  ssdz -n 5 -d /dev/sde -f  
