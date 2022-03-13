import ethers from "ethers"
import abi from "../ABI.json"

const main = async () => {
    const provider = new ethers.providers.JsonRpcProvider(
      process.env.infura
    );
  
    const wallet = new ethers.Wallet(
      process.env.walletPkey,
      provider
    );
    const contract = new ethers.Contract(
      "0xeb8a104180cf136c28e89928510c56ca4909510c",
      abi,
      wallet
    );

    contract.onTokenCreation( () => {
        //call insert or update endpoint on prism API
    })

    contract.tokenTransfer( () => {
        //call insert or update endpoint on prism API
    })
    
  };
  
  main();
  