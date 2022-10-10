resource "aws_security_group" "database" {
  vpc_id = data.aws_vpc.vpc.id
  name = "stk_devops_database"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    self = true
  }

}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "testdevopsdb"

  engine            = "postgres"
  engine_version    = "13.3"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5

  db_name  = "demodb"
  username = "userpostgstk"
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.database.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  create_db_subnet_group = true
  subnet_ids             = data.aws_subnet_ids.subnets.ids

  family = "postgres13"

  major_engine_version = "13.3"

  deletion_protection = false
}