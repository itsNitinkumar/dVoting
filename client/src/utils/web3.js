import Web3 from 'web3';
import VotingContract from "./Voting.json";

class getWeb3 {
  // how to polymorphically define a constructor in JS
  constructor(provider) {
    if (!provider) {
      this.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545/"));
    } else {
      this.web3 = new Web3(provider);
    }
  }


  
  async connectWeb3() {
    console.group("connecting without metamask....");
    const accounts = await this.web3.eth.getAccounts();
    const networkId = await this.web3.eth.net.getId();
    const deployedNetwork = await VotingContract.networks[networkId];
    const instance = new this.web3.eth.Contract(
        VotingContract.abi,
        deployedNetwork.address
    );
    console.log("connected successfully");
    return { accounts, instance }
  }

  async connectWeb3WithMetaMask() {
    console.group("connecting with metamask....");
    try {
      const accounts = await window.ethereum.request({ method: 'eth_accounts' });
      if (accounts.length === 0) {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        await window.ethereum.request({ method: 'eth_accounts' });
        const newAccounts = this.web3.eth.getAccounts();

        if (newAccounts.length === 0) {
          console.error('User denied account access or no accounts found.'); // if account is still not found 
          return null;
        }
      }
      
      const networkId = await this.web3.eth.net.getId();
      const deployedNetwork = await VotingContract.networks[networkId];
      
      const instance = new this.web3.eth.Contract(
          VotingContract.abi,
          deployedNetwork && deployedNetwork.address
      );
      console.log("connected successfully");
      return { accounts, instance }

    } catch (error) {
      console.error(`Error accessing accounts: ${error.message}`);
      return null;
    }
  }
}

export default getWeb3;