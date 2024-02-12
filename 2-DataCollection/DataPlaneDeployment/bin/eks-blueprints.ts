import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import * as blueprints from '@aws-quickstart/eks-blueprints';
import * as eks from 'aws-cdk-lib/aws-eks';

const app = new cdk.App();
const account = process.env.CDK_DEFAULT_ACCOUNT;
const region = process.env.CDK_DEFAULT_REGION;

const addOns: Array<blueprints.ClusterAddOn> = [
    // new blueprints.addons.ArgoCDAddOn(),
    // new blueprints.addons.CalicoOperatorAddOn(),
    // new blueprints.addons.MetricsServerAddOn(),
    new blueprints.addons.ClusterAutoScalerAddOn(),
    new blueprints.addons.AwsLoadBalancerControllerAddOn(),
    // new blueprints.addons.VpcCniAddOn(),
    // new blueprints.addons.CoreDnsAddOn(),
    // new blueprints.addons.KubeProxyAddOn(),
    new blueprints.addons.EbsCsiDriverAddOn(),
    new blueprints.addons.CloudWatchInsights(),
    new blueprints.addons.OpaGatekeeperAddOn()
];

const clusterProvider = new blueprints.GenericClusterProvider({
    version: eks.KubernetesVersion.V1_27,
    managedNodeGroups: [
        {
            id: "mng-ondemand",
            amiType: eks.NodegroupAmiType.AL2_X86_64,
            desiredSize: 2,
        }
    ]
});

const stack = blueprints.EksBlueprint.builder()
    .account(account)
    .region(region)
    .clusterProvider(clusterProvider)
    .addOns(...addOns)
    .useDefaultSecretEncryption(true) // set to false to turn secret encryption off (non-production/demo cases)
    .enableControlPlaneLogTypes(
        blueprints.ControlPlaneLogType.API,
        blueprints.ControlPlaneLogType.AUDIT,
        blueprints.ControlPlaneLogType.AUTHENTICATOR,
        blueprints.ControlPlaneLogType.CONTROLLER_MANAGER,
        blueprints.ControlPlaneLogType.SCHEDULER
        )
    .build(app, 'eks-blueprint', {description: 'Guidance for Personalized Engagement Using Online & Mobile User Behaviors on AWS - (SO9386)'});