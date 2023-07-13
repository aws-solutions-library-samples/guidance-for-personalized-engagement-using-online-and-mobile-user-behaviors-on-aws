import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import * as blueprints from '@aws-quickstart/eks-blueprints';

const app = new cdk.App();
const account = '<your_aws_account_id>';
const region = '<your_deploy_region>';

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
    new blueprints.addons.ContainerInsightsAddOn(),
];

const stack = blueprints.EksBlueprint.builder()
    .account(account)
    .region(region)
    .addOns(...addOns)
    .useDefaultSecretEncryption(true) // set to false to turn secret encryption off (non-production/demo cases)
    .build(app, 'eks-blueprint');