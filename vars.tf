variable "region" {
    description = "The region for the deployment"
    default = "us-west-2"
}
     
variable "vpc_id" {
    description = "The VPC ID where WordPress will reside"
    default = "vpc-04841a8f0654f9cc6"  
}
 
variable "ami_id" {
    description = "The AMI ID for AWS Linux 2 in us-west-2. In other regions, the ID is different"
    default = "ami-a9d09ed1"
 
}
 
variable "instance_type" {
    description = "AWS Instance type to be used for the WordPress instance"
    default = "t2.micro"
}
 
variable "volume_size" {
    description = "EBS volume size in GBs for the instance"
    default = 8
}
 
variable "key_name" {
    description = "The key pair that will be used to log to the server using SSH"
    default = "MyKeyPair-Oregon"
}
 
variable "ssh_port" {
    description = "The SSH port for the server"
    default = 22
}
 
variable "http_port" {
    description = "The HTTP port for the server"
    default = 80
}
 
variable "mysql_port" {
    description = "The MySQL port for the database"
    default = 3306
}
 
variable "nfs_port" {
    description = "The NFS port for the shared filesystem"
    default = 2049
}
 
variable "allocated_storage" {
    description = "The size in GBs of the SQL database"
    default = 10
}
 
variable "instance_class" {
    description = "The size/type of the SQL instance"
    default = "db.t2.micro"
}
 
variable "db_admin" {
    description = "The dbadmin username"
    default = "dbadmin"
}
 
variable "db_password" {
    description = "The dbadmin password"
    default = "SuperSecret"
}
 
variable "db_name" {
    description = "The database name"
    default = "dbwordpress"
}
