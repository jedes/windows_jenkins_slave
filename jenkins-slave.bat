@echo off

REM Usage jenkins-slave.bat [options] -url http://jenkins [SECRET] [AGENT_NAME]
REM Optional environment variables :
REM * JENKINS_TUNNEL : HOST:PORT for a tunnel to route TCP traffic to jenkins host, when jenkins can't be directly accessed over network
REM * JENKINS_URL : alternate jenkins URL
REM * JENKINS_SECRET : agent secret, if not set as an argument
REM * JENKINS_AGENT_NAME : agent name, if not set as an argument
REM * JENKINS_AGENT_WORKDIR : agent work directory, if not set by optional parameter -workDir

SETLOCAL ENABLEDELAYEDEXPANSION

if "%1"=="" (

	REM if `docker run` only has one argument, we assume user is running alternate command like `cmd` to inspect the image
	cmd %*

) else (
	rem if -tunnel is not provided try env vars
	for %%i in (%*) do if "%%i"=="-tunnel" goto :has_tunnel
	if not "!JENKINS_TUNNEL!"=="" (set TUNNEL=-tunnel !JENKINS_TUNNEL!)
:has_tunnel
	rem resume after label...

	if not "!JENKINS_AGENT_WORKDIR!"=="" (
		for %%i in (%*) do if "%%i"=="-workDir" (
			echo "Warning: Work directory is defined twice in command-line arguments and the environment variable"
			goto :workdir_defined
		)
		set WORKDIR=-workDir !JENKINS_AGENT_WORKDIR!
	)
:workdir_defined
	rem resume after label...
	
	if not "!JENKINS_URL!"=="" set URL=-url !JENKINS_URL!

	if not "!JENKINS_NAME!"=="" set JENKINS_AGENT_NAME=!JENKINS_NAME!

	if "!JNLP_PROTOCOL_OPTS!"=="" (
		echo "Warning: JnlpProtocol3 is disabled by default, use JNLP_PROTOCOL_OPTS to alter the behavior"
		set JNLP_PROTOCOL_OPTS=-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true
	)

	rem If both required options are defined, do not pass the parameters
	set OPT_JENKINS_SECRET=
	if not "!JENKINS_SECRET!"=="" (
		for %%i in (%*) do if "%%i"=="!JENKINS_SECRET!" (
			echo "Warning: SECRET is defined twice in command-line arguments and the environment variable"
			goto :secret_defined
		)
		set OPT_JENKINS_SECRET=!JENKINS_SECRET!
	)
:secret_defined
	rem resume after label...

	
	set OPT_JENKINS_AGENT_NAME=
	if not "!JENKINS_AGENT_NAME!"=="" (
		for %%i in (%*) do if "%%i"=="!JENKINS_AGENT_NAME!" (
			echo "Warning: AGENT_NAME is defined twice in command-line arguments and the environment variable"
			goto :agent_name_defined
		)
		set OPT_JENKINS_AGENT_NAME=!JENKINS_AGENT_NAME!
	)
:agent_name_defined
	rem resume after label...

	java !JAVA_OPTS! !JNLP_PROTOCOL_OPTS! -cp c:\jenkins_slave\slave.jar hudson.remoting.jnlp.Main -headless !TUNNEL! !URL! !WORKDIR! !OPT_JENKINS_SECRET! !OPT_JENKINS_AGENT_NAME! %*
)