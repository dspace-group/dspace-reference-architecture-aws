MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

%{ if length(pre_userdata) > 0 ~}
# User-supplied pre userdata
${pre_userdata}
%{ endif ~}
%{ if format_mount_nvme_disk ~}
echo "Format and Mount NVMe Disks if available"
IDX=1
DEVICES=$(lsblk -o NAME,TYPE -dsn | awk '/disk/ {print $1}')

for DEV in $DEVICES
do
  mkfs.xfs /dev/$${DEV}
  mkdir -p /local$${IDX}

  echo /dev/$${DEV} /local$${IDX} xfs defaults,noatime 1 2 >> /etc/fstab

  IDX=$(($${IDX} + 1))
done
mount -a
%{ endif ~}
%{ if length(service_ipv4_cidr) > 0 ~}
export SERVICE_IPV4_CIDR=${service_ipv4_cidr}
%{ endif ~}
%{ if length(service_ipv6_cidr) > 0 ~}
export SERVICE_IPV6_CIDR=${service_ipv6_cidr}
%{ endif ~}

%{ if strcontains(ami_type, "AL2023") ~}
echo "Bootstrapping Amazon Linux 2023 with nodeadm"
nodeadm init \
  --cluster-name ${eks_cluster_id} \
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_ca_base64} \
  --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
%{ else ~}
echo "Bootstrapping AL2 or Ubuntu with bootstrap.sh"
/etc/eks/bootstrap.sh ${eks_cluster_id} \
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_ca_base64} \
  --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
%{ endif ~}

%{ if length(post_userdata) > 0 ~}
# User-supplied post userdata
${post_userdata}
%{ endif ~}
--//--
