pipeline {
    environment { 
        HOME = "$WORKSPACE"
    }
    agent {
        docker {
            image 'jayabalan/puppetalpine:1.0'
        }
    }
    stages {
        stage('validate') {
            steps {
                sh 'find ./ -type f -name *.pp | xargs puppet parser validate'
            }
        }
        stage('Build Puppet module') {          
            steps {
                sh 'puppet module build .'
            }
        }
        stage('Publish in Jfrog') {
            steps{
                stepPushArtifacts("*.tar.gz", "si-puppet")                          
            }
        }
    }
}
