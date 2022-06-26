import { ethers } from "ethers";
import { useContext, useEffect, useState } from "react";
import { MetaMaskContext } from "../contexts/MetaMask";

const PoolABI = require('../abi/Pool.json');

const subscribeToEvents = (pool, callback) => {
  pool.once("Mint", (a, b, c, d, e, f, g, event) => callback(event));
  pool.once("Swap", (a, b, c, d, e, f, g, event) => callback(event));
}

const renderAmount = (amount) => {
  return ethers.utils.formatUnits(amount);
}

const renderMint = (args) => {
  return (
    <span>
      <strong>Mint</strong>
      [range: [{args.tickLower}-{args.tickUpper}], amounts: [{renderAmount(args.amount0)}, {renderAmount(args.amount1)}]]
    </span>
  );
}

const renderSwap = (args) => {
  return (
    <span>
      <strong>Swap</strong>
      [amount0: {renderAmount(args.amount0)}, amount1: {renderAmount(args.amount1)}]
    </span>
  );
}

const renderEvent = (event, i) => {
  let content;

  switch (event.event) {
    case 'Mint':
      content = renderMint(event.args);
      break;

    case 'Swap':
      content = renderSwap(event.args);
      break;
  }

  return (
    <li key={i}>{content}</li>
  )
}

const isMintOrSwap = (event) => {
  return event.event === "Mint" || event.event === 'Swap';
}

const EventsFeed = (props) => {
  const config = props.config;
  const metamaskContext = useContext(MetaMaskContext);
  const [events, setEvents] = useState([]);
  const [pool, setPool] = useState();

  useEffect(() => {
    if (metamaskContext.status !== 'connected') {
      return;
    }

    if (!pool) {
      const newPool = new ethers.Contract(
        config.poolAddress,
        PoolABI,
        new ethers.providers.Web3Provider(window.ethereum)
      );

      subscribeToEvents(newPool, (event) => setEvents(events.concat(event)));
      setPool(newPool);
    }
  }, [metamaskContext.status, events, pool, config]);

  return (
    <ul className="py-6">
      {events.reverse().filter(isMintOrSwap).map(renderEvent)}
    </ul>
  );
}

export default EventsFeed;