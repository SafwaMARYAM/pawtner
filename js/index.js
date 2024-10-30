// Function to fetch pet data from the server
async function fetchPets() {
    try {
		let pets = {
    		data: []
		};

        const response = await fetch('fetch_pets.php');
        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }
        const petData = await response.json();
        // Map the fetched data to the desired structure
        pets.data = petData.map(pet => ({
            petName: pet.pet_name,
            image: pet.image,
            description: pet.description,
            age: pet.age,
            breed: pet.breed,
            size: pet.size,
            gender: pet.gender,
            shelter: {
                name: pet.shelter_name,
                place: pet.shelter_place,
                phone: pet.shelter_phone,
            },
            volunteer: {
                id: pet.volunteer_id,
                name: pet.volunteer_name,
            },
            category: pet.category || 'Dog' // Default category
        }));
		for(let i of pets.data){
			//create card
			let card = document.createElement("div");
			//card should have category and stay hidden initially
			card.classList.add("card", i.category, "hide");
		
			//image div
			let imgContainer = document.createElement("div");
			imgContainer.classList.add("image-container");
		 
			//image tag
			let image = document.createElement("img");
			image.setAttribute("src", i.image);
			imgContainer.appendChild(image);
			card.appendChild(imgContainer);
		
			//container
			let container = document.createElement("div");
			container.classList.add("container");
		
			// pet name
			let name = document.createElement("h4");
			name.classList.add("pet-name");
			name.innerText = i.petName;
			container.appendChild(name);
			
			// gender
			let gender = document.createElement("h9");
			gender.innerText = `Gender: ${i.gender}`; // Add label
			container.appendChild(gender);
			
			// age
			let age = document.createElement("h9");
			age.innerText = `Age: ${i.age}`; // Add age
			container.appendChild(age);
			
			// breed
			let breed = document.createElement("h9");
			breed.innerText = `Breed: ${i.breed}`; // Add breed
			container.appendChild(breed);
			
			// size
			let size = document.createElement("h9");
			size.innerText = `Size: ${i.size}`; // Add size
			container.appendChild(size);
			
			// shelter details
			let shelterDetails = document.createElement("h9");
			shelterDetails.innerText = `Shelter: ${i.shelter.name}, ${i.shelter.place}, Phone: ${i.shelter.phone}`; // Add shelter details
			container.appendChild(shelterDetails);
			
			// volunteer details
			let volunteerDetails = document.createElement("h9");
			volunteerDetails.innerText = `Volunteer: ${i.volunteer.name}, ID: ${i.volunteer.id}`; // Add volunteer details
			container.appendChild(volunteerDetails);
			
			// description
			let description = document.createElement("h9");
			description.innerText = i.description; // Fix: Use 'description' instead of 'gender'
			container.appendChild(description);

			//adopt button
			let adoptButton = document.createElement("button6");
			adoptButton.classList.add("adopt-button");
			adoptButton.innerText = "Adopt";
			container.appendChild(adoptButton);
		
			adoptButton.addEventListener("click", () => {
				alert(`${i.petName} adopted successfully!`); // Display success message
				card.classList.add("hide"); // Optionally hide the card after adoption
			});
		
			card.appendChild(container);
			console.log(card.innerHTML);
			document.getElementById("pets").appendChild(card);
		}		
        console.log(pets.data); // Output the pets object to the console for verification
    } catch (error) {
        console.error('Error fetching pet data:', error);
    }
}

//parameter passed from button 

function filterProduct(value){
	//button class code
	let buttons = document.querySelectorAll(".button-value");
	buttons.forEach((button) => {
		//check if value equals innerText
		if(value.toUpperCase()== button.innerText.toUpperCase()){
			button.classList.add("active");
		}else{
			button.classList.remove("active");
		}	
	});

	//select all cards
	let elements = document.querySelectorAll(".card");
	//loop through all cards
	elements.forEach((element) => {
		//display all cards on "all" button click
		if(value == "all") {
			element.classList.remove("hide");
		   }
		   else{
			   //check if element contains category class
			   if(element.classList.contains(value)){
				   //display element based on category
				   element.classList.remove("hide");
			   }
			   else{
				   //hide their elements
				   element.classList.add("hide");
			   }
			}
	});
}
//search button click
//will implement this later
/*document.getElementById("search").addEventListener("click", () =>{
    //initializations
    let searchInput = document.getElementById("search-input").value;
    let elements = document.querySelectorAll(".pet-name");
    let cards = document.querySelectorAll(".card");
    console.log(searchInput);

    //loop through all elements
    elements.forEach((element,index)=>{
        //check if text includes the search value
        if(element.innertext.includes(searchInput.toUpperCase())){
            //display matching card
            cards[index].classList.remove("hide");
        }
        else{
            //hide others
            cards[index].classList.add("hide");
        }
    }) 
});
*/

//initially display all products
window.onload =() => {
	fetchPets();
    filterProduct("all");
};



//  slider part
/*$(".custom-carousel").owlCarousel({
	autoWidth: true,
	loop: true
  });*/
  $(document).ready(function () {
	$(".custom-carousel .item").click(function () {
	  $(".custom-carousel .item").not($(this)).removeClass("active");
	  $(this).toggleClass("active");
	});
  });

  // Click function for show the Modal
// Create an immediately invoked functional expression to wrap our code
(function() {

	// Define our constructor 
	this.Modal = function() {
  
	  // Create global element references
	  this.closeButton = null;
	  this.modal = null;
	  this.overlay = null;
  
	  // Determine proper prefix
	  this.transitionEnd = transitionSelect();
  
	  // Define option defaults 
	  var defaults = {
		autoOpen: false,
		className: 'fade-and-drop',
		closeButton: true,
		content: "",
		maxWidth: 600,
		minWidth: 280,
		overlay: true
	  }
  
	  // Create options by extending defaults with the passed in arugments
	  if (arguments[0] && typeof arguments[0] === "object") {
		this.options = extendDefaults(defaults, arguments[0]);
	  }
  
	  if(this.options.autoOpen === true) this.open();
  
	}
  
	// Public Methods
  
	Modal.prototype.close = function() {
	  var _ = this;
	  this.modal.className = this.modal.className.replace(" scotch-open", "");
	  this.overlay.className = this.overlay.className.replace(" scotch-open",
		"");
	  this.modal.addEventListener(this.transitionEnd, function() {
		_.modal.parentNode.removeChild(_.modal);
	  });
	  this.overlay.addEventListener(this.transitionEnd, function() {
		if(_.overlay.parentNode) _.overlay.parentNode.removeChild(_.overlay);
	  });
	}
  
	Modal.prototype.open = function() {
	  buildOut.call(this);
	  initializeEvents.call(this);
	  window.getComputedStyle(this.modal).height;
	  this.modal.className = this.modal.className +
		(this.modal.offsetHeight > window.innerHeight ?
		  " scotch-open scotch-anchored" : " scotch-open");
	  this.overlay.className = this.overlay.className + " scotch-open";
	}
  
	// Private Methods
  
	function buildOut() {
  
	  var content, contentHolder, docFrag;
  
	  /*
	   * If content is an HTML string, append the HTML string.
	   * If content is a domNode, append its content.
	   */
  
	  if (typeof this.options.content === "string") {
		content = this.options.content;
	  } else {
		content = this.options.content.innerHTML;
	  }
  
	  // Create a DocumentFragment to build with
	  docFrag = document.createDocumentFragment();
  
	  // Create modal element
	  this.modal = document.createElement("div");
	  this.modal.className = "scotch-modal " + this.options.className;
	  this.modal.style.minWidth = this.options.minWidth + "px";
	  this.modal.style.maxWidth = this.options.maxWidth + "px";
  
	  // If closeButton option is true, add a close button
	  if (this.options.closeButton === true) {
		this.closeButton = document.createElement("button");
		this.closeButton.className = "scotch-close close-button";
		this.closeButton.innerHTML = "&times;";
		this.modal.appendChild(this.closeButton);
	  }
  
	  // If overlay is true, add one
	  if (this.options.overlay === true) {
		this.overlay = document.createElement("div");
		this.overlay.className = "scotch-overlay " + this.options.className;
		docFrag.appendChild(this.overlay);
	  }
  
	  // Create content area and append to modal
	  contentHolder = document.createElement("div");
	  contentHolder.className = "scotch-content";
	  contentHolder.innerHTML = content;
	  this.modal.appendChild(contentHolder);
  
	  // Append modal to DocumentFragment
	  docFrag.appendChild(this.modal);
  
	  // Append DocumentFragment to body
	  document.body.appendChild(docFrag);
  
	}
  
	function extendDefaults(source, properties) {
	  var property;
	  for (property in properties) {
		if (properties.hasOwnProperty(property)) {
		  source[property] = properties[property];
		}
	  }
	  return source;
	}
  
	function initializeEvents() {
  
	  if (this.closeButton) {
		this.closeButton.addEventListener('click', this.close.bind(this));
	  }
  
	  if (this.overlay) {
		this.overlay.addEventListener('click', this.close.bind(this));
	  }
  
	}
  
	function transitionSelect() {
	  var el = document.createElement("div");
	  if (el.style.WebkitTransition) return "webkitTransitionEnd";
	  if (el.style.OTransition) return "oTransitionEnd";
	  return 'transitionend';
	}
  
  }());
  
  var myContent = document.getElementById('content');
  
  var myModal = new Modal({
	content: myContent
  });
  
  /*var bookButton = document.getElementById('trigger');
  
  bookButton.addEventListener('click', function() {
	myModal.open();
  });*/

