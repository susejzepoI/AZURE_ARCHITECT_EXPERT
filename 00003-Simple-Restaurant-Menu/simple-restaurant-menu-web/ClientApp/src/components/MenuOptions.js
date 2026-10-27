import {useEffect, useState} from 'react';

export function MenuOptions(){
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(()=>{
    async function populateMenuOptions(){
      try{
        const response = await fetch('/menuoptions');
        const data = await response.json();
        setOptions(data);
      }catch(requestError){
        setError(requestError);
      }finally{
        setLoading(false);
      }  
    }

    populateMenuOptions();
  },[]);

  if (loading){
    return <p>Loading...</p>;
  }

  if (error) {
    return <p role="alert">Error: {error.message}</p>;
  }

  return (
    <section>
      <h1>Our Menu Options</h1> 
      <div className="menu-options__bar" role="group" aria-label="Menu categories">
        {options.map((option) => (
          <button
            key={option}
            type="button"
            className="menu-options__button"
          >
            {option.replaceAll('-', ' ')}
          </button>
        ))}
      </div>
    </section>
  );
}
