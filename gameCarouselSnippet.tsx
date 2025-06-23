const GameCarousel: React.FC<CraneOverlayProps> = ({ games }) => {
  //var for concatenating until done
  var loopingGames = [];
  //minimum number of cards required to fill screen; may be calculable from site styling, but couldn't find location (Turns out that the cards seem to be fixed-width and non-scaling, judging from me zooming in and out, meaning it's non-calculable atm)
  const minCards = 8;
  //in a try catch loop due to potential for divide by 0 errors if the passed argument is empty or doesn't support the length() function
  try{ 
    //from 0 until i is equal to the number of repetitions of the base set of objects required to reach the minimum number of cards to fill the screen
    //Couldn't find an easier way to assign a constant to be another constant repeated X times.
    for (var i=0; i < (Math.ceil(minCards/games.length)); i++) {
      loopingGames = [...loopingGames,...games];
    } 
    //sets it to the existing constant
    const loopedGames = loopingGames;
    //copy-pasted return code; we don't want to return if it fails the try I think?
    return (
      <div className={styles.carouselWrapper}>
        <div className={styles.carousel}>
          {loopedGames.map((game, index) => (
            <GamePreviewCard key={index} {...game} />
          ))}
        </div>
      </div>
    );
  }
  catch(e) { 
    console.error(e); 
    return(<p>Something went REALLY wrong if you're seeing this rendered.</p>);
  }
};
