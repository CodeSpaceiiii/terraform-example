variable "ak" {
  type    = string
}

variable "sk" {
  type    = string
}

provider "alicloud" {
  access_key = "${var.ak}"
  secret_key = "${var.sk}"
  region     = "cn-hangzhou"
}

data "alicloud_vpcs" "vpcs_ds" {
  status     = "Available"
  name_regex = "^default-NODELETING"
}

output "first_vpc_id" {
  value = "${data.alicloud_vpcs.vpcs_ds.vpcs.0.id}"
}

# 创建vswitch
data "alicloud_zones" "foo" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vswitch" "foo" {
  vswitch_name = "terraform-example-yuangen"
  cidr_block   = "10.0.2.0/24"
  vpc_id       = data.alicloud_vpcs.vpcs_ds.vpcs.0.id
  zone_id      = data.alicloud_zones.foo.zones.0.id
}

# 创建安全组
resource "alicloud_security_group" "group" {
  name   = "security_group_yuangen"
  vpc_id = data.alicloud_vpcs.vpcs_ds.vpcs.0.id
}

# 创建ECS
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

#默认的资源组信息
data "alicloud_resource_manager_resource_groups" "example" {
    name_regex = "default"
}

resource "alicloud_instance" "instance" {
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = alicloud_security_group.group.*.id

  # series III
  instance_type              = "ecs.i2.xlarge"
  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "test_foo_system_disk_name"
  system_disk_description    = "test_foo_system_disk_description"
  image_id                   = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  instance_name              = "test_foo"
  vswitch_id                 = alicloud_vswitch.foo.id
  internet_max_bandwidth_out = 10
  tags = {
    name = "yuangen"
  }
  resource_group_id = data.alicloud_resource_manager_resource_groups.example.groups.0.id
}

## 调用模块开启安全组规则
module "service_sg_with_source_sg_id" {
  source  = "alibaba/security-group/alicloud"

  name        = "user-service"
  description = "Security group for user-service with custom rules of source security group."
  vpc_id      = data.alicloud_vpcs.vpcs_ds.vpcs.0.id

  ingress_cidr_blocks      = ["120.245.22.0/24"]
  ingress_rules            = ["https-443-tcp"]
  ingress_ports = [22]
  ingress_with_cidr_blocks_and_ports = [
    {
      ports       = "22"
      protocol    = "tcp"
      priority    = 1
      cidr_blocks = "120.245.22.0/24"
    }
  ]
}

## 创建OSS
resource "random_integer" "default" {
  max = 99999
  min = 10000
}

resource "alicloud_oss_bucket" "default" {
  bucket = "example-value-${random_integer.default.result}"
  acl    = "private"
}

# 组织一个JSON文件供OSS上传
locals {
  example_object = {
    instance_id = alicloud_instance.instance.id
    private_address = alicloud_instance.instance.private_ip
  }

  example_json = jsonencode(local.example_object)
}

resource "alicloud_oss_bucket_object" "default" {
  bucket  = alicloud_oss_bucket.default.bucket
  key     = "ecs_basic_info.txt"
  content = local.example_json
}

