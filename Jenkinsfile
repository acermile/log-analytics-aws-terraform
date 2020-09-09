@Library(['terraform-pipeline-global-lib@master']) _

Jenkinsfile.init(this)

ParameterStoreBuildWrapperPlugin.withPathPattern { options -> "/acermile/${options['environment']}/${options['repoName']}" }
                                .init()
AnsiColorPlugin.init()          // REQUIRED: Decorate your TerraformEnvironmentStages with the AnsiColor plugin
//def validate = new TerraformValidateStage()
//def deployQa = new TerraformEnvironmentStage('qa').build()
def deployQA = new TerraformEnvironmentStage('qa').build()
def testQa = new RegressionStage().build()
//def deployUat = new TerraformEnvironmentStage('uat').build()
//def testUat = new RegressionStage().build()
