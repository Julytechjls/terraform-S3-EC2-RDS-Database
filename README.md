Step 1: Set up an EC2 instance on AWS
    • Sign in to the AWS console and navigate to EC2.
    • Click "Launch Instance" to launch a new instance.
    • Select an Amazon Linux AMI
    • Select the t2.micro instance type
    • Make sure you properly configure your security settings (allow HTTP and SSH traffic).
    • Create a new key pair key or use an existing one to access your instance using SSH.
    • Launch the instance.
Step 2: Connect to the EC2 instance using SSH
    • Use your SSH client to connect to your EC2 instance using the public IP address provided by AWS and the key pair key on Cloud9
Step 3: Install and configure Apache web server
    • Once connected to the EC2 instance, run the following commands:
        ◦ sudo yum update -y
        ◦ sudo yum install httpd -y
        ◦ sudo service httpd start
        ◦ sudo chkconfig httpd on
    • Navigate to the web server directory:
        ◦ cd /var/www/html
    • Run the following commands
        ◦ sudo yum install php php-cli php-json php-mbstring –y
        ◦ sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ◦ sudo php composer-setup.php
        ◦ sudo php -r "unlink('composer-setup.php');"
        ◦ sudo php composer.phar require aws/aws-sdk-php
        ◦ sudo service httpd restart

Step 4: Create an HTML Form
    • Navigate to the root directory of the web server:
        ◦ cd /var/www/html
    • Create an HTML file called index.html with a form:

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Contact Form</title>
</head>
<body>
<h1>Contact Form</h1>
<form action="submit.php" method="POST">
<label for="name">Name:</label><br>
<input type="text" id="name" name="name" required><br>
<label for="email">Email:</label><br>
<input type="email" id="email" name="email" required><br>
<label for="message">Message:</label><br>
<textarea id="message" name="message" rows="4" required></textarea><br>
<input type="submit" value="Submit">
</form>
</body>
</html>




Step 5: Create a PHP script to process the form
    • Create a PHP file called submit.php in the same directory
        ◦ Replace the “snsTopicArn” variable with the ARN of your SNS that will be created in the last point of the practice.



<?php
require 'vendor/autoload.php';
 
use Aws\Sns\SnsClient;
use Aws\Exception\AwsException;
 
if ($_SERVER["REQUEST_METHOD"] == "POST") {
$name = $_POST["name"];
$email = $_POST["email"];
$message = $_POST["message"];
 
// Replace 'your-sns-topic-arn' with the ARN of your SNS topic
$snsTopicArn = 'arn:aws:sns:us-east-1:XXXXXXX:test';
 
// Initialize SNS client
$snsClient = new SnsClient([
'version' => 'latest',
'region' => 'us-east-1' // Replace with your desired AWS region
]);
 
// Create message to send to SNS topic
$messageToSend = json_encode([
'email' => $email,
'name' => $name,
'message' => $message
]);
 
try {
// Publish message to SNS topic
$snsClient->publish([
'TopicArn' => $snsTopicArn,
'Message' => $messageToSend
]);
 
echo "Message sent successfully.";
} catch (AwsException $e) {
echo "Error sending message: " . $e->getMessage();
}
} else {
http_response_code(405);
echo "Method Not Allowed";
}
?>





    • Create a test PHP file at /var/www/html:
<?php phpinfo(); ?>



    • Access the test PHP file :
Open a web browser and navigate to the public IP address of your EC2 instance followed by /info.php (for example, http://your_public_ip/info.php ). You should see the PHP information in your browser if the configuration was successful.
    • Check the Apache server configuration :
Make sure the Apache configuration file ( httpd.conf ) includes the AddType directive for PHP. You can find the configuration file in /etc/httpd/conf/httpd.conf .
Add this line to the file
AddType application/x-httpd-php .php
    • Add Role to EC2
        ◦ Let's go to the EC2 console, go to actions -> security -> Add Role
        ◦ We choose the Role “LabRole”
        ◦ Then we go to the IAM service and look for this Role, and add the “AWSSSNSFullAccess” policy

    • Create lambda
        ◦ Create a lambda, choose Python 3.12, and in “permissions” choose the Role “LabRol”
        ◦ Add the following code to the lambda
import urllib3
import json
http = urllib3.PoolManager()
def lambda_handler(event, context):
url = "https://hooks.slack.com/services/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"
msg = {
"channel": "#devops",
"username": "abdessamad.ammi",
"text": event['Records'][0]['Sns']['Message'],
"icon_emoji": ""
}
    
encoded_msg = json.dumps(msg).encode('utf-8')
resp = http.request('POST',url, body=encoded_msg)
print({
"message": event['Records'][0]['Sns']['Message'],
"status_code": resp.status,
"response": resp.data
})

        ◦ Deploy the Lambda to confirm its creation.

    • Create an SNS topic
        ◦ Create an SNS topic, choose “lambda” as the protocol, and paste the lambda ARN.

Once all the steps are done, we access the public IP of the instance in the browser, and fill out the form. Once sent, we should receive a message in the Slack channel created for this practice with the information from the form.

Note: This is all about the work, but you must do it with terraform
