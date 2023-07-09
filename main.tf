# 创建一个子账号
resource "alicloud_ram_user" "user" {
  name         = "terraform-practice-yuangen"
  display_name = "yuangen"
  comments     = "terraform-practice"
  force        = true
}

# ECS/VPC/OSS的系统权限
resource "alicloud_ram_policy" "policy_for_test" {
  policy_name     = "policyForEcsVpcOss"
  policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": "ecs:*",
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "vpc:*HaVip*",
          "vpc:*RouteTable*",
          "vpc:*VRouter*",
          "vpc:*RouteEntry*",
          "vpc:*RouteEntries*",
          "vpc:*VSwitch*",
          "vpc:*Vpc*",
          "vpc:*Cen*",
          "vpc:*Tag*",
          "vpc:*NetworkAcl*",
          "vpc:*FlowLog*",
          "vpc:*Ipv4Gateway*",
          "vpc:*PrefixList*",
          "vpc:*DhcpOptionsSet*",
          "vpc:DeletionProtection",
          "vpc:*TagResource*",
          "vpc:MoveResourceGroup"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": "oss:*",
        "Effect": "Allow",
        "Resource": "*"
      }
    ],
    "Version": "1"
  }
  EOF
  description     = "this is a policy for ecs/vpc/oss full"
  force           = true
}

# 将权限加给用户
resource "alicloud_ram_user_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.policy_for_test.name
  policy_type = alicloud_ram_policy.policy_for_test.type
  user_name   = alicloud_ram_user.user.name
}

# 创建一个AK
resource "alicloud_ram_access_key" "ak" {
  user_name   = alicloud_ram_user.user.name
  secret_file = "/tmp/ak.txt"
}

output "ak" {
  value = alicloud_ram_access_key.ak.id
}

output "sk" {
  value = alicloud_ram_access_key.ak.secret
  sensitive = true
}

module "step2" {
  source = "./step2-module"
  ak = alicloud_ram_access_key.ak.id
  sk = alicloud_ram_access_key.ak.secret
}