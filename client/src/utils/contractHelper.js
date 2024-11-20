import web3 from './web3';
import Voting from  './Voting.json';

export const getContractInstance = async () => {
    const networkId = await web3.eth.net.getId();
    const deployedNetwork = Voting.networks[networkId];

    if (!deployedNetwork) {
        throw new Error("Smart contract not deployed on this network.");
    }

    const contract = new web3.eth.Contract(
        Voting.abi, 
        deployedNetwork && deployedNetwork.address
    );

    return contract;
};