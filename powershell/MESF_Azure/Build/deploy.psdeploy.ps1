Deploy TestDeployment {

    By FileSystem Modules {
        FromSource MESF_Azure
        To D:\devel\temp\TestDeployment
        Tagged Dev, Module
        WithOptions @{
            Mirror = $true
        }
    }
}