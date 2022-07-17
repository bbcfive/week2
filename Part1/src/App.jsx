import { useState } from 'react'
import { ethers } from 'ethers'

const addressContract = "" // to be deployed
const abi = [] // to be compiled

let provider = new ethers.providers.Web3Provider(window.ethereum)
let signer = provider.getSigner()
let contract = new ethers.Contract(addressContract, abi, provider)
let signerContract = await contract.connect(signer)

const App = () => {
  const [msg, setMsg] = useState('')
  const [leaf, setLeaves] = useState('')
  const [hash, setHashes] = useState('')
  const [verification, setVerifications] = useState()
  const connect = async () => {
    await provider.send('eth_requestAccounts', [])
    let singerMsg = await signer.getAddress()
    setMsg(singerMsg)
    console.log(msg)
  }

  const insertLeaf = () => {
    const res = await signerContract.functions.insertLeaf(leaf)
    setHashes(res)
  }

  const verify = (a, b, c, input) => {
    const res = await signerContract.functions.verify(a, b, c, input)
    setVerifications(res)
  }

  return (
    <div>
      Connected to {address}
      <button onClick={() => connect()}>Connect to Metamask</button>
      <text>
        Insert <input onChange={(e) => setLeaves(e.target.value)} /> leaves
      </text>
      <button onClick={() => insertLeaf()}>Insert {leaf} leaves</button>
      <text>The Merkle Tree root is {hash}</text>
      <button onClick={() => verify()}>To verify</button>
      <text>The varification result is {verification}</text>
    </div>
  )
}

export default App
