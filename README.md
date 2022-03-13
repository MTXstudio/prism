# prism-eth-global

## Architecture 

Polygon enables the decentralised storage of ownership records for traits (ERC1155 - semi-fungible tokens) as well as the parent NFT. The parent NFT inherits the metadata from the combination of traits. The metadata connected to the traits and parent NFT are stored in tableland. Tableland enables immutable storage for trait metadata and mutable storage of parent NFT metadata. The images for all traits are stored on IPFS. When the user configers the parent NFT via the prism front-end, the metadata is for the parent NFT is adjusted. The trait metadata stays immutably the same. 

When a user sells a trait, TheGraph records the change on trait ownership and removes the potentially equipped trait from the users parent NFT via tableland.


## Components

Prism is using a number of open source and commercial projects to enable the service

/// DLT & Testing Compontents
- Polygon - Decentralised Ledger for storing fungible and non-fungible tokens 
- ERC-1155 - Token Standard combining fungible and non-fungible tokens
- Hardhat - Ethereum development environment.
- Typescript - Strongly Typed JS
- Typechain - TS Types for Solidity Smart Contracts
- Node - JS runtime

/// Data Querying and Availability 
- Tableland - Mutable and Immutable Metadata storage in SQL Tables  
- TheGraph - Accessing blockchain events (To be build and added to Repo)
- IPFS - Decentralised storage network used of artworks and trait images

/// Front-end components
- Next JS
- React JS
- Tailwind CSS
- Web3 modal


## Test Build 

https://mtx-labs-prism.netlify.app/

## Deployed Contracts

| Contract Name | Chain | Address |

| Prism Contract | Polygon Mumbai Testnet | 0xEb8A104180CF136c28E89928510c56Ca4909510c
