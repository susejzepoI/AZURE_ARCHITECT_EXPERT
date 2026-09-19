import {useEffect, useState} from 'react';

export function FetchMenuOptions(){
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(true);

  async function populateMenuOptions(){
    const response = await fetch('/menuoptions');
    const data = await response.json();
    setOptions(data);
    setLoading(false);
  }

  useEffect(()=>{
    populateMenuOptions();
  },[]);

  if (loading){
    return <p>Loading...</p>;
  }

  return (
    <ul>
      {options.map((option) => (
        <li key={option}>{option}</li>
      ))}
    </ul>
  );
}
