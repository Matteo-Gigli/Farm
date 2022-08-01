# Farm


<h2>📝 Farm Contract</h2>
<br>

<p><strong>I just created a Farm Contract where users can farm their eth and choose the rewards method of payments</strong></p>
<p><strong>Rewards method of payments are via: Token or Eth</strong></p>
<br>

<h2>🔍 Contracts Detail</h2>
<br>

<h3>💰 TokenFarm.sol</h3>
<br>
<p><strong>Simple Erc20 Token where we are going to override some functions</strong></p>
<p><strong>As usual, to use this contract, we must to pass some parameters as name, symbol, totalSupply for our new Token.</strong></p>
<br>

<h3>📊 DataFarm.sol</h3>
<br>

<p><strong>This is the contract where whe store all the information about, what happens in Farm.sol</strong></p>
<p><strong>We can find set-get function, working for the Farm.sol contract.</strong></p>
<p><strong>Once the contract is deployed we have to use the initFarm function(), passing the Farm contract address
and the initTokenFarm function(), passing the TokenFarm contract address.</strong></p>
<p><strong>This create a pointer to the Farm and the TokenFarm contract, necessary to work with all the contracts togheter.</strong></p>
<p><strong>That means, if i put something in farm, in the Farm.sol contract, the DataFarm.sol will receive all the information, populate a Struct for each farm,
and store this data.</strong></p>
<p><strong></strong></p>
<p><strong></strong></p>


<h3🌱 Farm.sol</h3>
21
<br>
<p><strong></strong></p>
31
<p><strong></strong></p>
