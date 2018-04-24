FROM  octasic/dotnet_and_jdk

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN [Environment]::SetEnvironmentVariable('JENKINS_AGENT_VERSION', '3.16', [EnvironmentVariableTarget]::Machine)

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ;\
	mkdir c:\jenkins_slave;\
	mkdir c:\jenkins_work;\
	Invoke-WebRequest -Uri "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${Env:JENKINS_AGENT_VERSION}/remoting-${env:JENKINS_AGENT_VERSION}.jar" -OutFile 'c:\jenkins_slave\slave.jar' -UseBasicParsing ;

COPY jenkins-slave.bat c:/jenkins_slave/jenkins-slave.bat

VOLUME c:\\jenkins_slave
WORKDIR c:\\jenkins_work

ENV JENKINS_AGENT_WORKDIR c:\\jenkins_work


ENTRYPOINT ["c:\\jenkins_slave\\jenkins-slave.bat"]