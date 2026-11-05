import {useEffect, useState} from 'react';

export function MenuOptions(){
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(()=>{
    async function populateMenuOptions(){
      try{
        const response = await fetch('/menuoptions');
        if (!response.ok) {
          const message = await response.text();
          throw new Error(message || `Request failed with status ${response.status}`);
        }

        const data = await response.json();
        if (!Array.isArray(data)) {
          throw new Error('The menu options response was not a list.');
        }

        setOptions(data);
      }catch(requestError){
        setError(requestError instanceof Error ? requestError : new Error('Unable to load menu options.'));
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
      <div className="menu-options__content">
      </div>  
    </section>
  );
}
