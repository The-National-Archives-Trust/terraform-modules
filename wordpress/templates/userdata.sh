#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster} > /etc/ecs/ecs.config

sudo yum update -y ecs-init

sudo mkdir /mnt/wordpress

sudo service docker restart
