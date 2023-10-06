#########
#author:uday
#date:07/10

####

#aws ec2
#aws s3
#aws iam users

#list of aws instance in aws
echo -e "\e[33mThis is ec2 instance list.\e[0m"
aws ec2 describe-instances

#list of aws s3 buckets in aws
echo -e "\e[32mThis is s3 bucket  list.\e[0m"
aws s3 ls

#list of aws iam users
echo -e "\e[31mThis is iam users list.\e[0m"
aws iam list-users
