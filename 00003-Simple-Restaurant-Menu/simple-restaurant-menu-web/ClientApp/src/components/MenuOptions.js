import {useEffect, useState} from 'react';

export function MenuOptions(){
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedOption, setSelectedOption] = useState(null);
  const [images, setImages] = useState([]);
  const [imagesLoading, setImagesLoading] = useState(false);
  const [imagesError, setImagesError] = useState(null);

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

  useEffect(() => {
    if (!selectedOption) {
      return undefined;
    }

    const abortController = new AbortController();

    async function populateImages() {
      setImages([]);
      setImagesError(null);
      setImagesLoading(true);

      try {
        const response = await fetch(
          `/menuoptions/${encodeURIComponent(selectedOption)}/images`,
          { signal: abortController.signal }
        );
        if (!response.ok) {
          const message = await response.text();
          throw new Error(message || `Request failed with status ${response.status}`);
        }

        const data = await response.json();
        if (!Array.isArray(data)) {
          throw new Error('The menu images response was not a list.');
        }

        setImages(data);
      } catch (requestError) {
        if (requestError.name !== 'AbortError') {
          setImagesError(
            requestError instanceof Error
              ? requestError
              : new Error('Unable to load menu images.')
          );
        }
      } finally {
        if (!abortController.signal.aborted) {
          setImagesLoading(false);
        }
      }
    }

    populateImages();
    return () => abortController.abort();
  }, [selectedOption]);

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
            aria-pressed={selectedOption === option}
            onClick={() => setSelectedOption(option)}
          >
            {option.replaceAll('-', ' ')}
          </button>
        ))}
      </div>
      <div className="menu-options__content">
        {selectedOption && (
          <section aria-labelledby="selected-menu-heading">
            <h2 id="selected-menu-heading">
              {selectedOption.replaceAll('-', ' ')}
            </h2>
            {imagesLoading && <p>Loading images...</p>}
            {imagesError && <p role="alert">Error: {imagesError.message}</p>}
            {!imagesLoading && !imagesError && images.length === 0 && (
              <p>No images were found in this category.</p>
            )}
            {!imagesLoading && !imagesError && images.length > 0 && (
              <div className="menu-images" aria-live="polite">
                {images.map((image) => (
                  <figure className="menu-images__item" key={image.name}>
                    <img
                      src={image.imageUrl}
                      alt={image.name.split('/').pop().replaceAll('-', ' ')}
                      loading="lazy"
                    />
                    <figcaption>
                      {image.name.split('/').pop().replaceAll('-', ' ')}
                    </figcaption>
                  </figure>
                ))}
              </div>
            )}
          </section>
        )}
      </div>  
    </section>
  );
}
