# :ear: Who's listening? 
This is a [BitBar](https://github.com/matryer/bitbar) plugin that displays processes listenting on the public network

## Problem this is trying to solve
When developing (server) software you at times may run local servers which may leak (confidential) information or make yourself vulnerable to attacks, especially when on public networks like cafe wifi or that like.

Common fix for this is to use a local firewall and/or bind servers to localhost, so that they are not reachable from the public network. However this is easy to forget leaving your inadverably vulnerable. 

This plugin will try to detect some of these situations and make them visible to you. It is also opnionated about some services/settings.


## What it does
On regular intervals (90 sec) the plugin checks
 * If your MacOS firewall is disabled, in this case it will display a ":fearful: Firwall is disabled"
 * If any processes are listening on TPC other than the loopback interface, it will display a :fire:  together with the process name. 
 * You also have the option to ignore a certain alert for 24h hours, this is the "I know what I am doing" function.

## Limitations
 * UDP is ignored
 * Launchers like xinted are ignored (for now)
 * When firewall is active, it is currently not checked whether a specific service is (already) blocked by firewall, so you see false positives.
 * 'rapportd' a component believed to belong to iTunes/Homekit is not reported on purpose. Drop me a line of you have details. 
 

