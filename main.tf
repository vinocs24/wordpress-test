provider "aws" {
    region = var.region
}
 
resource "aws_security_group" "sgWordPress" {
    name = "sgWordPress"
    vpc_id      = var.vpc_id
 
    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks =["0.0.0.0/0"]
    }
 
    ingress {
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        from_port = var.mysql_port
        to_port = var.mysql_port
        protocol = "tcp"
        self = true
    }
 
    ingress {
        from_port = var.nfs_port
        to_port = var.nfs_port
        protocol = "tcp"
        self = true
    }
 
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    tags = {
        Name = "sgWordPress"
    }
}
 
resource "aws_efs_file_system" "efsWordPress" {
  creation_token = "EFS for WordPress"
 
  tags = {
    Name = "EFS for WordPress"
  }
}
 
data "aws_subnet_ids" "suballIDs" {
    vpc_id = data.aws_vpc.suballIDs.id
}
 
resource "aws_efs_mount_target" "mtWordPress" {
  count = length(data.aws_subnet_ids.suballIDs.ids)
  file_system_id = aws_efs_file_system.efsWordPress.id
  subnet_id      = element(data.aws_subnet_ids.suballIDs.ids, count.index)
  security_groups = [aws_security_group.sgWordPress.id]
}
 
resource "aws_instance" "wordpress" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sgWordPress.id]
    key_name = var.key_name
    ebs_block_device {
        device_name = "/dev/sdb"
        volume_size = var.volume_size
        delete_on_termination = "true"
    }
 
    tags = {
        Name = "WordPress Server"
    }
 
    user_data = <<EOF
        #!/bin/bash
        echo "${aws_efs_file_system.efsWordPress.dns_name}:/ /var/www/html nfs defaults,vers=4.1 0 0" >> /etc/fstab
        yum install -y php php-dom php-gd php-mysql
        for z in {0..120}; do
            echo -n .
            host "${aws_efs_file_system.efsWordPress.dns_name}" && break
            sleep 1
        done
        cd /tmp
        wget https://www.wordpress.org/latest.tar.gz
        mount -a
        tar xzvf /tmp/latest.tar.gz --strip 1 -C /var/www/html
        rm /tmp/latest.tar.gz
        chown -R apache:apache /var/www/html
        systemctl enable httpd
        sed -i 's/#ServerName www.example.com:80/ServerName www.myblog.com:80/' /etc/httpd/conf/httpd.conf
        sed -i 's/ServerAdmin root@localhost/ServerAdmin admin@myblog.com/' /etc/httpd/conf/httpd.conf
        #setsebool -P httpd_can_network_connect 1
        #setsebool -P httpd_can_network_connect_db 1
        systemctl start httpd
        #firewall-cmd --zone=public --permanent --add-service=http
        #firewall-cmd --reload
        #iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
        #iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    EOF
 
}
 
resource "aws_db_instance" "dbWordPress" {
    identifier = "dbwordpress"
    engine = "mysql"
    engine_version = "5.7"
    allocated_storage = var.allocated_storage
    instance_class = var.instance_class
    vpc_security_group_ids = [aws_security_group.sgWordPress.id]
    name = var.db_name
    username = var.db_admin
    password = var.db_password
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot = true
    tags = {
        Name = "WordPress DB"
    }
}
