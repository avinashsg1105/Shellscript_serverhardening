
Command to run the script.

Sudo bash final.sh



Assumptions:
1)1 VCPU And 1 GB ram, assuming the configuration which you have given I made use of the t2.micro server to completely develop and test the script.
2)Server hardening nowadays are mostly depending on the security groups and nacls more than the internal firewall itself, i made only a few firewall rules to harden the server.


Requirements:
1)bash script to create users
	On user creation, enable ssh access to users using 'PublicKey' PROVIDED BY THE
USER.
	i)Devops user with sudo access and should be in devops group.
	ii)Dev users in Dev group and has access to read/write/execute access on directory
'/opt/sayurbox/sample-web-app' and all its sub directories.
	iii)Dev users should have Read only access to '/var/log/*.log'.


2)bash script to make 
i)server readiness, hardening, and firewall rules.
ii)Server ready for hosting a MongoDB database and a web application.
iii)Enable log rotation with 14 days log retency, with log files archived by date.


Improvements that could have been implemented:
1) could have used case or functions instead of multiple if functions being used, but i felt using if could avoid some security issues.
2)command reusability could have been reduced.

