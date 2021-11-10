pipeline {
    agent any
    stages {
        stage('Repo-Clonning') {
          steps {
            git branch: 'main', url: 'https://github.com/mjmanas0699/dotsquare/'
            sh '''
            mkdir -p  ~/tasks
            sudo cp -rvf * ~/tasks/
            sudo cp -r .git   ~/tasks/
           '''
          }
        }
          stage('Create Repository') {
            steps {
                sh'''
                    echo '#/bin/bash
                    aws ecr describe-repositories --repository-name=test-cli
                    a=$?
                    if [[ $a -eq 0 ]];
                    then
                        echo "Repo present"
                    else
                        aws ecr create-repository --repository-name test-cli
                        echo "Repo Creation Done"
                    fi'  > test.sh
                    bash test.sh
                    '''
        }
     }
     stage('Build and Push the Image To ECR') {
        steps {
             sh ''' #/bin/bash
                    pwd
                    export repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                    cd ~/tasks/ && export last_commit=$(git rev-parse HEAD)
                    sudo docker build -t $repo_name:$last_commit -f ~/tasks/Dockerfile .
                    aws ecr get-login-password --region ap-south-1 | sudo docker login --username AWS --password-stdin $(echo $repo_name | awk -F / '{print $1}')
                    sudo docker push $repo_name:$last_commit
                 '''
        }
    }
    stage('Create EKS Cluster If Not Exists') {
    steps {
        sh '''
            echo '#/bin/bash
            aws eks describe-cluster --name test-cluster
            a=$?
            if [[ $a -eq 0 ]];
            then
                echo "Cluster Present"
            else
                eksctl create cluster -f ~/tasks/config.yaml
                echo "Cluster Creation Done"
            fi' > ~/tasks/test.sh
            bash ~/tasks/test.sh
        '''
      }
    }
    stage('Add Kubeconfig') {
    steps {
        sh ''' aws eks --region ap-south-1 update-kubeconfig --name test-cluster '''
     }
   }
   stage('Deploy to Cluster') {
    steps {
        sh'''
                export repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                cd ~/tasks/ && export last_commit=$(git rev-parse HEAD)
                sudo sed -i 's|image_name|'${repo_name}:${last_commit}'|g' ~/tasks/kube/deployment.yaml
                kubectl apply -f ~/tasks/kube/
         '''
    }
}
}

}