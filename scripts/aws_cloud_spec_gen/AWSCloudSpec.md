
# <a name="Category_Compute"></a> ![Compute](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/Compute.png) Compute

## <a name="Service_Amazon Elastic Compute Cloud"></a> ![Amazon Elastic Compute Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2.png) Amazon Elastic Compute Cloud

### <a name="Resource_Elastic IP address"></a>![Elastic IP address](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2ElasticIPAddress.png) Elastic IP address
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc-eu-central-1a | tbd | tbd |

### <a name="Resource_Launch template"></a>Launch template
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:ec2:eu-central-1:778206098013:launch-template/lt-0d5e2f51c20049e91 | tbd | tbd |
| arn:aws:ec2:eu-central-1:778206098013:launch-template/lt-058ea20279979c296 | tbd | tbd |
| arn:aws:ec2:eu-central-1:778206098013:launch-template/lt-051038058588b811a | tbd | tbd |
| arn:aws:ec2:eu-central-1:778206098013:launch-template/lt-0b99cc0de9b7bb977 | tbd | tbd |
| arn:aws:ec2:eu-central-1:778206098013:launch-template/lt-0ecf0fc5ab24040de | tbd | tbd |

## <a name="Service_Amazon EC2 Auto Scaling"></a> ![Amazon EC2 Auto Scaling](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2AutoScaling.png) Amazon EC2 Auto Scaling

# <a name="Category_Containers"></a> ![Containers](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/Containers.png) Containers

## <a name="Service_Amazon Elastic Kubernetes Service"></a> ![Amazon Elastic Kubernetes Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/ElasticKubernetesService.png) Amazon Elastic Kubernetes Service

### <a name="Resource_Cluster"></a>Cluster
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:eks:eu-central-1:778206098013:cluster/vr-simphera | tbd | tbd |

### <a name="Resource_Add-on"></a>Add-on
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:eks:eu-central-1:778206098013:addon/vr-simphera/kube-proxy/d0cc2005-a0f2-7e89-e919-dfa7c31f2ce0 | tbd | tbd |
| arn:aws:eks:eu-central-1:778206098013:addon/vr-simphera/vpc-cni/cecc2004-21f3-6388-bdae-331752a7afdf | tbd | tbd |
| arn:aws:eks:eu-central-1:778206098013:addon/vr-simphera/aws-ebs-csi-driver/64cc2005-a0f9-e8b6-159d-181de6b8bba0 | tbd | tbd |
| arn:aws:eks:eu-central-1:778206098013:addon/vr-simphera/coredns/e0cc2005-9f94-eefb-db64-ae9be1a3a0b7 | tbd | tbd |
| arn:aws:eks:eu-central-1:778206098013:addon/vr-simphera/aws-efs-csi-driver/90cc2005-a12f-fcc8-8a93-719b878c0b87 | tbd | tbd |

### <a name="Resource_Node group"></a>Node group
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-default | tbd | tbd |
| vr-simphera-gpuivsnodes | tbd | tbd |
| vr-simphera-execnodes | tbd | tbd |
| vr-simphera-winexecnodes | tbd | tbd |
| vr-simphera-gpuexecnodes-550-90-07 | tbd | tbd |

# <a name="Category_Database"></a> ![Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/Database.png) Database

## <a name="Service_Amazon Relational Database"></a> ![Amazon Relational Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/RDS.png) Amazon Relational Database

### <a name="Resource_PostgreSQL instance"></a>![PostgreSQL instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/AuroraPostgreSQLInstance.png) PostgreSQL instance
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:rds:eu-central-1:778206098013:db:vr-simphera-instancename-simphera | tbd | tbd |
| arn:aws:rds:eu-central-1:778206098013:db:vr-simphera-instancename-keycloak | tbd | tbd |

### <a name="Resource_Subnet group"></a>Subnet group
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:rds:eu-central-1:778206098013:subgrp:vr-simphera-instancename-vpc | tbd | tbd |

# <a name="Category_Management & Governance"></a> ![Management & Governance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/ManagementGovernance.png) Management & Governance

## <a name="Service_Amazon CloudWatch"></a> ![Amazon CloudWatch](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatch.png) Amazon CloudWatch

### <a name="Resource_Log groups"></a>![Log groups](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatchLogs.png) Log groups
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/ssm/vr-simphera/install | tbd | tbd |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/rds/instance/vr-simphera-instancename-keycloak/postgresql | tbd | tbd |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/vpc/vr-simphera | tbd | tbd |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/eks/vr-simphera/cluster | tbd | tbd |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/rds/instance/vr-simphera-instancename-simphera/postgresql | tbd | tbd |
| arn:aws:logs:eu-central-1:778206098013:log-group:/aws/ssm/vr-simphera/scan | tbd | tbd |

# <a name="Category_Networking & Content Delivery"></a> ![Networking & Content Delivery](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/NetworkingContentDelivery.png) Networking & Content Delivery

## <a name="Service_Amazon Virtual Private Cloud"></a> ![Amazon Virtual Private Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VirtualPrivateCloud.png) Amazon Virtual Private Cloud

### VPC Requirements

| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR block | Network size ie. number of available IPs in VPC | 10.1.0.0/18 | yes |
| Availability zones | How many AZs to spread VPC across | 3 (at least 2 for high availability) | yes |
| Private subnets | How many private subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| Public subnets | How many public subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| NAT gateway | Enable/disable NAT in VPC | enable | yes |
| Single NAT gateway | Controls how many NAT gateways/Elastic IPs to provision | enable | no |
| Internet gateway | Enable/disable IGW in VPC | enable | yes |
| DNS hostnames | Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses. | enable | yes |

### <a name="Resource_Internet gateway"></a>![Internet gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCInternetGateway.png) Internet gateway
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc | tbd | tbd |

### <a name="Resource_NAT gateway"></a>![NAT gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCNATGateway.png) NAT gateway
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc-eu-central-1a | tbd | tbd |

### <a name="Resource_Route table"></a>Route table
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc-default | tbd | tbd |
| vr-simphera-vpc-private | tbd | tbd |
| vr-simphera-vpc-public | tbd | tbd |

### <a name="Resource_Security group"></a>Security group
<table>
<tr><th>Group name</th><th>Group description</th><th>Direction</th><th>Protocol</th><th>Port range</th><th>Rule description</th></tr>
<tr><td rowspan="8">eks-cluster-sg-vr-simphera-1760095786</td><td rowspan="8">EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads.</td><td>inbound</td><td>tcp</td><td>80</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>inbound</td><td>tcp</td><td>80</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>inbound</td><td>tcp</td><td>80</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>inbound</td><td>All</td><td>All</td><td>Allows EFA traffic, which is not matched by CIDR rules.</td></tr><tr><td>inbound</td><td>tcp</td><td>443</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>inbound</td><td>tcp</td><td>443</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>inbound</td><td>tcp</td><td>443</td><td>elbv2.k8s.aws/targetGroupBinding=shared</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td></td></tr>
<tr><td rowspan="1">vr-simphera-db-sg</td><td rowspan="1">PostgreSQL security group</td><td>inbound</td><td>tcp</td><td>5432</td><td>PostgreSQL access from within VPC</td></tr>

<tr><td rowspan="4">vr-simphera-license-server</td><td rowspan="4">License server security group</td><td>inbound</td><td>tcp</td><td>22350</td><td>Inbound TCP on port 22350 from kubernetes nodes security group</td></tr><tr><td>inbound</td><td>tcp</td><td>5053</td><td>Allow ingoing RTMaps license request (rlm)</td></tr><tr><td>inbound</td><td>tcp</td><td>60403</td><td>Allow ingoing RTMaps license request (IVS intempora)</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td>allow all outbound traffic</td></tr>
</table>

### <a name="Resource_Subnet"></a>Subnet
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc-public-eu-central-1b | tbd | tbd |
| vr-simphera-vpc-private-eu-central-1a | tbd | tbd |
| vr-simphera-vpc-private-eu-central-1c | tbd | tbd |
| vr-simphera-vpc-public-eu-central-1c | tbd | tbd |
| vr-simphera-vpc-private-eu-central-1b | tbd | tbd |
| vr-simphera-vpc-public-eu-central-1a | tbd | tbd |

### Private subnets requirements

| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per private subnet | 10.1.0.0/22 <br /> 10.1.4.0/22 <br /> 10.1.8.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "private" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |

### Public subnets requirements

| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per public subnet | 10.1.12.0/22 <br /> 10.1.16.0/22 <br /> 10.1.20.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "public" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |

### 'Private' route table requirements

| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| Routes | Minimum routes for network communication to work | 0.0.0.0/0 to \<NAT gateway> <br /> \<vpcCidrBlock> to local | yes |
| Subnet associations | Apply route table routes to a particular subnet | Explicit, all private subnets | yes |

### 'Public' route table requirements

| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| Routes | Minimum routes for network communication to work | 0.0.0.0/0 to \<Internet gateway> <br /> \<vpcCidrBlock> to local | yes |
| Subnet associations | Apply route table routes to a particular subnet | Explicit, all public subnets | yes |

### <a name="Resource_Virtual Private Cloud"></a>Virtual Private Cloud
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| vr-simphera-vpc | tbd | tbd |

## <a name="Service_Elastic Load Balancing"></a> ![Elastic Load Balancing](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancing.png) Elastic Load Balancing

### <a name="Resource_Network Load Balancer"></a>![Network Load Balancer](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancingNetworkLoadBalancer.png) Network Load Balancer

# <a name="Category_Storage"></a> ![Storage](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/Storage.png) Storage

## <a name="Service_Amazon Simple Storage Service"></a> ![Amazon Simple Storage Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageService.png) Amazon Simple Storage Service

### <a name="Resource_Bucket"></a>![Bucket](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageServiceBucket.png) Bucket
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:s3:::ivs-raw-data-vr | tbd | tbd |
| arn:aws:s3:::ivs-data-vr | tbd | tbd |
| arn:aws:s3:::vr-simphera-license-server-bucket | tbd | tbd |
| arn:aws:s3:::vr-simphera-logs | tbd | tbd |
| arn:aws:s3:::vr-simphera-instancename | tbd | tbd |

# <a name="Category_Analytics"></a> ![Analytics](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/Analytics.png) Analytics

## <a name="Service_Amazon OpenSearch Service"></a> ![Amazon OpenSearch Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/OpenSearchService.png) Amazon OpenSearch Service

### <a name="Resource_Domain"></a>Domain
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:es:eu-central-1:778206098013:domain/vr-simphera-ivsstage | tbd | tbd |

# <a name="Category_Security, Identity, & Compliance"></a> ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## <a name="Service_AWS Key Management Service"></a> ![AWS Key Management Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/KeyManagementService.png) AWS Key Management Service

### <a name="Resource_Customer managed keys"></a>Customer managed keys
| Name | Description | Mandatory? |
| ---- | ----------- | ---------- |
| arn:aws:kms:eu-central-1:778206098013:key/1a1f2c6f-2cec-4907-84b9-2c38bb01a3e5 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/8b76aedb-e100-4063-ae19-3577c382c88b | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/4b6af5da-372a-42bf-b451-b592ae4789ab | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/73234403-fa49-42be-b228-da1285a7312b | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/a57af8c3-c03d-433f-b107-35c5f600c4c8 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/996ad765-d76d-4dd3-84f4-94c01d9b2f7e | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/bbb23337-9eea-4d0b-a881-275e310b9d80 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/5f2c8c64-922e-40c7-a7c3-de9c7a942c98 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/615c4e65-1cee-4b4f-b077-eb1a897649c0 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/0ec8d2a5-cf60-4e03-ab46-ef399f2e03dc | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/c2ee3375-ae71-446b-8d14-eda816d2905a | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/efc43b69-11b7-4bad-a398-0ada91b397b5 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/75d7ad9f-d59c-4e95-a40d-ce63a0cc4b79 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/c0d2d345-3de7-4355-9a24-d960916e881a | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/54cc6e13-18d0-400d-9a8d-1a4e0c339854 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/f2ed698b-907e-4eb4-ae4e-36d6bc065fb2 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/4b9bfb7f-7076-4f17-b6f6-7c9d49a518d0 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/ce9708af-196c-4beb-872b-c4c1a9f92200 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/19a54648-8acb-48dd-b2c1-158483fc97e4 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/05924122-5db3-4543-bada-e187733f63a4 | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/3cc8ea1c-8917-406d-90f1-a05614c8398b | tbd | tbd |
| arn:aws:kms:eu-central-1:778206098013:key/a12995c5-73b6-44c3-ac5c-b1d68528c19e | tbd | tbd |

# ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## ![AWS Identity and Access Management](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityandAccessManagement.png) AWS Identity and Access Management

### ![Role](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementRole.png) Role
| Role name | Description | Policies  |
| --------- | ----------- | --------- |
|instancename-executoragentlinux|AWS IAM Role for the Kubernetes service account minio-irsa.|<ul><li>[vr-simphera-instancename-s3-policy](#vr-simphera-instancename-s3-policy)</li></ul>|
|instancename-rds-enhanced-monitoring|AWS AM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs.|<ul><li>[AmazonRDSEnhancedMonitoringRole](#AmazonRDSEnhancedMonitoringRole)</li></ul>|
|vr-simphera-aws-load-balancer-controller-sa-irsa|AWS IAM Role for the Kubernetes service account aws-load-balancer-controller-sa.|<ul><li>[vr-simphera-aws-load-balancer-controller-irsa](#vr-simphera-aws-load-balancer-controller-irsa)</li></ul>|
|vr-simphera-aws-node-irsa|AWS IAM Role for the Kubernetes service account aws-node.|<ul><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|vr-simphera-cluster-autoscaler-sa-irsa|AWS IAM Role for the Kubernetes service account cluster-autoscaler-sa.|<ul><li>[vr-simphera-cluster-autoscaler-irsa](#vr-simphera-cluster-autoscaler-irsa)</li></ul>|
|vr-simphera-cluster-role|AWS IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations.|<ul><li>[AmazonEKSClusterPolicy](#AmazonEKSClusterPolicy)</li><li>[AmazonEKSVPCResourceController](#AmazonEKSVPCResourceController)</li><li>vr-simphera-cluster-role</li></ul>|
|vr-simphera-default|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|vr-simphera-ebs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account ebs-csi-controller-sa.|<ul><li>[AmazonEBSCSIDriverPolicy](#AmazonEBSCSIDriverPolicy)</li></ul>|
|vr-simphera-efs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account efs-csi-controller-sa.|<ul><li>[AmazonEFSCSIDriverPolicy](#AmazonEFSCSIDriverPolicy)</li></ul>|
|vr-simphera-execnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|vr-simphera-flowlogs-role|AWS IAM service role for VPC flow logs.|<ul><li>[vr-simphera-flowlogs-policy](#vr-simphera-flowlogs-policy)</li></ul>|
|vr-simphera-gpuexecnodes-550-90-07|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|
|vr-simphera-gpuivsnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|vr-simphera-instancename-s3-role|IAM role for the MinIO service account|<ul><li>[vr-simphera-instancename-s3-policy](#vr-simphera-instancename-s3-policy)</li></ul>|
|vr-simphera-ivsstage-ivs-sa-role||<ul><li>vr-simphera-ivsstage-ivs-sa-access-policy</li></ul>|
|vr-simphera-license-server-role|IAM role used for the license server instance profile.|<ul><li>[vr-simphera-license-server-policy](#vr-simphera-license-server-policy)</li><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li></ul>|
|vr-simphera-winexecnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|

### ![Policies](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementPermissions.png) Policies
| Policy name | Description | Managed By |
| ----------- | ----------- | ---------- | 
|<a name="vr-simphera-instancename-s3-policy"></a>[vr-simphera-instancename-s3-policy](./)|Allows access to S3 bucket.|Customer|
|<a name="AmazonRDSEnhancedMonitoringRole"></a>[AmazonRDSEnhancedMonitoringRole](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonRDSEnhancedMonitoringRole)|Provides access to Cloudwatch for RDS Enhanced Monitoring|AWS|
|<a name="vr-simphera-aws-load-balancer-controller-irsa"></a>[vr-simphera-aws-load-balancer-controller-irsa](./)|AWS Load Balancer Controller IAM policy|Customer|
|<a name="AmazonEKS_CNI_Policy"></a>[AmazonEKS_CNI_Policy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKS_CNI_Policy)|This policy provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IP address configuration on your EKS worker nodes. This permission set allows the CNI to list, describe, and modify Elastic Network Interfaces on your behalf. More information on the AWS VPC CNI Plugin is available here: https://github.com/aws/amazon-vpc-cni-k8s|AWS|
|<a name="vr-simphera-cluster-autoscaler-irsa"></a>[vr-simphera-cluster-autoscaler-irsa](./)|Cluster Autoscaler IAM policy|Customer|
|<a name="AmazonEKSClusterPolicy"></a>[AmazonEKSClusterPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSClusterPolicy)|This policy provides Kubernetes the permissions it requires to manage resources on your behalf. Kubernetes requires Ec2:CreateTags permissions to place identifying information on EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces. |AWS|
|<a name="AmazonEKSVPCResourceController"></a>[AmazonEKSVPCResourceController](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSVPCResourceController)|Policy used by VPC Resource Controller to manage ENI and IPs for worker nodes.|AWS|
|<a name="AmazonSSMManagedInstanceCore"></a>[AmazonSSMManagedInstanceCore](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonSSMManagedInstanceCore)|The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.|AWS|
|<a name="AmazonEC2ContainerRegistryReadOnly"></a>[AmazonEC2ContainerRegistryReadOnly](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEC2ContainerRegistryReadOnly)|Provides read-only access to Amazon EC2 Container Registry repositories.|AWS|
|<a name="AmazonEKSWorkerNodePolicy"></a>[AmazonEKSWorkerNodePolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSWorkerNodePolicy)|This policy allows Amazon EKS worker nodes to connect to Amazon EKS Clusters.|AWS|
|<a name="AmazonEBSCSIDriverPolicy"></a>[AmazonEBSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEBSCSIDriverPolicy)|IAM Policy that allows the CSI driver service account to make calls to related services such as EC2 on your behalf.|AWS|
|<a name="AmazonEFSCSIDriverPolicy"></a>[AmazonEFSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEFSCSIDriverPolicy)|Provides management access to EFS resources and read access to EC2|AWS|
|<a name="vr-simphera-flowlogs-policy"></a>[vr-simphera-flowlogs-policy](./)||Customer|
|<a name="vr-simphera-license-server-policy"></a>[vr-simphera-license-server-policy](./)|Allows access to S3 bucket and Secure Session Manager connections.|Customer|