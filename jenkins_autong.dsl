/**
 * @author Shwetank Vashishtha
 *
 */

def branchesParam = binding.variables.get('BRANCHES')
def branches = branchesParam ? branchesParam.split(' ') : ['1.0.0', '1.0.0-SNAPSHOT']

// generic params
def constants = [
project: 'AutoNG',
component: '(QA Fiction)',
branches: branches,
name: 'AutoNG',
label: '',
username: ''
]

def friendlyProject = constants.project.capitalize()
def friendlyComponent = constants.component.capitalize()
folder(constants.component) {
displayName("${friendlyProject} ${friendlyComponent}")
}

for (branch in constants.branches) {
postflightJob(constants, branch)
}

def postflightJob(constants, branch) {
def friendlyBranch = branch.capitalize()
def friendlyLabel = constants.name.capitalize()

// Sets a display name for the project.
return mavenJob("${constants.component}/${branch}-${constants.name}") {
displayName("${friendlyLabel} ${friendlyBranch}").with {
description ''
}

// Root pom.xml path
rootPOM("pom.xml")

// Set goals and option to execute with maven
goals("clean package")

// Allows Jenkins to schedule and execute multiple builds concurrently.
concurrentBuild()

// Label which specifies which nodes this job can run on.
label(constants.label)

// Manages how long to keep records of the builds.
logRotator {
// If specified, only up to this number of builds have their artifacts retained.
artifactNumToKeep(50)
// If specified, only up to this number of build records are kept.
numToKeep(50)
}

//// Block any upstream and downstream projects while building current project
//configure {
//def aNode = it
//def anotherNode = aNode / 'blockBuildWhenDownstreamBuilding'
//anotherNode.setValue('true')
//(it / 'blockBuildWhenUpstreamBuilding').setValue('true')
//}

// Adds pre/post actions to the job.
wrappers {
preBuildCleanup()
colorizeOutput()
timestamps()
buildName('#${dev}')
}

scm {
git {
remote {
github('ShwetankVashishtha/AutoNG')
credentials('GitHub_Creds_SV')
url('https://github.com/ShwetankVashishtha/AutoNG.git')
}

extensions {
cloneOptions {
timeout(10)
}
                }
            }
        }

triggers {
configure { it / 'triggers' / 'com.cloudbees.jenkins.GitHubPushTrigger' / 'spec' }
scm('* H * * *')
}

// Allows to publish archive artifacts
publishers {
archiveArtifacts('**/target/*.jar')
}
}
}