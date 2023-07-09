### Terraform练习内容

使用 Terraform 完成如下动作：
1. 使用已有 AK1 创建一个名为 terraform-practice-<你的姓名> 的 ram user
2. 为新的 ram user 绑定 ecs，vpc，oss 的系统策略
3. 在新的ram user 下创建一个新的AK，并使用新的 AK2 完成接下来的操作
4. 通过 data source 查询一个名为 default-NODELETING 的vpc，并在 vpc 下创建一个 vswitch 和 安全组
5. 利用创建好的 vswitch 和安全组创建一个 ubuntu 18 的ECS 实例，并为其打上你的姓名的tag，并将其加入到默认资源组中
6. 为 ECS设置安全规则，开放 22 端口，但是只允许公司办公网访问（例如网段：8.8.5.0/24）
7. 创建一个私有的 OSS bucket，并将 ECS 实例的ID和私网地址上传到 OSS 上