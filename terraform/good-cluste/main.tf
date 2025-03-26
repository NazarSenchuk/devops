provider "aws" {
  region = "us-east-1"  # Вкажіть ваш регіон
}


module "vpc" {  
    source = "./modules/vpc/"
    
}





