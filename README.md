# Farm


<h2>📝 Farm Contract</h2>
<br>

<p><strong>I just created a Farm Contract where users can farm their eth and choose the rewards method of payments.</strong></p>
<p><strong>Rewards method of payments are via: Token or Eth.</strong></p>
<br>

<h2>🔍 Contracts Detail</h2>
<br>

<h3>💰 TokenFarm.sol</h3>
<br>
<p><strong>Simple Erc20 Token where we are going to override some functions.</strong></p>
<p><strong>As usual, to use this contract, we must to pass some parameters as name, symbol, totalSupply for our new Token.</strong></p>
<br>

<h3>📊 DataFarm.sol</h3>
<br>

<p><strong>This is the contract where we store all the information about what happens in Farm.sol</strong></p>
<p><strong>We can find set-get function, working for the Farm.sol contract.</strong></p>
<p><strong>Once the contract is deployed we have to use the initFarm function(), passing the Farm contract address
and the initTokenFarm function(), passing the TokenFarm contract address.</strong></p>
<p><strong>This create a pointer to the Farm and the TokenFarm contract, necessary to work with all the contracts togheter.</strong></p>
<p><strong>That means, if i put something in farm, in the Farm.sol contract, the DataFarm.sol will receive all the information, populate a Struct for each farm,
and store this data.</strong></p>
<p><strong></strong></p>
<p><strong></strong></p>
<br>

<h3>🌱 Farm.sol</h3>
<br>
<p><strong>This is the contract contains the function to farm and unfarm our eth.</strong></p>
<p><strong>To deploy this contract we must to pass some parameters as farmingDate1 and farmingDate2 (this are the months allowed for farming)</strong></p>
<p><strong>and the tokenPercentReward and the ethPercentReward (this are the percent of rewards for, token rewards or eth reward).</strong></p>
<p><strong>Must to follow some rules for the last 2 parameters, like ethPercentReward must to be in a range of 0 (not included) and 10% (included), and
tokenPercentReward must to be in a range of 0 (not included) and 40%(included).</strong></p>
<br>
<p><strong>tokenPercentReward are always > ethPercentReward.</strong></p>
<br>
<p><strong>As before the functions to start with are the initDataFarm and the TokenFarm (passing DataFarm address and TokenFarm address).</strong></p>
<p><strong>As we can see from the contract, later we have a bunch of "calculating functions" necessary to divide the logic behind the expectation rewards</strong></p>
<p><strong>in fact we have to calculate rewards for Tokens if you choose tokens as rewards, or eth if you choose eth as rewards.</strong></p>
<p><strong>We will make that choose(eth or Token rewards), using the farming function().</strong></p>
<p><strong>As we can see, to use this function we must to pass 2 parameter and a value.</strong></p>
<p><strong>Parameters are farmingDate and paymentChoosed.</strong></p>
<p><strong>FarmingDate must be equal to farmingDate1 or farmingDate2.</strong></p>
<p><strong>PaymentChoosed must be equal to: Token, TOKEN, token  or  ETH, Eth, eth.</strong></p>
<br>
<p><strong></strong></p>
<p><strong>To unfarm we pay a fee to the farm like:</strong></p>
<p><strong>eth rewards = 5% for Farm on the rewards.</strong></p>
<p><strong>token rewards = 2% for Farm on the deposit amount.</strong></p>
<br>


<h2>🔧 Built With</h2>
<br>
<p><strong>Solidity, Hardhat</strong></p>
<p><strong></strong></p>
