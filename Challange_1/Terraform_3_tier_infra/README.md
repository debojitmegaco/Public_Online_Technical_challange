#### 3 Tier Application

### Considerations
- VPC is already Created
- 3 Tier application with following layers
  - A DB Layer with No-SQL AWS Dynamodb
  - An Application Instance Layer, where Instance created from an Application AMI where, application is designed to connect Dynamodb
  - Application Instance will be created under Private subnet, and managed by Auto Scaling Group
  - A Classic Load Balancer in Public Subnet Associated
  - Hosted Zone already created
  - Record Set Already Created
  - A ACM attached to Load Balancer
