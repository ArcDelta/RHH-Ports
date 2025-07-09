async function loadPorts() {
    const container = document.getElementById('ports-container');
    const countDisplay = document.getElementById('port-count');
    const filterDropdown = document.getElementById('genre-filter');
    const availabilityDropdown = document.getElementById('availability-filter');
    const sortDropdown = document.getElementById('sort-select');

    try {
        const res = await fetch('ports.json');
        if (!res.ok) throw new Error('Failed to load ports.json');
        const ports = await res.json();

        if (!ports.length) {
            container.textContent = 'No ports found.';
            return;
        }

        // Collect all genres
        const genreSet = new Set();
        ports.forEach(port => (port.genres || []).forEach(genre => genreSet.add(genre)));
        const allGenres = Array.from(genreSet).sort();

        // Populate genre dropdown
        for (const genre of allGenres) {
            const option = document.createElement('option');
            option.value = genre;
            option.textContent = genre.charAt(0).toUpperCase() + genre.slice(1);;
            filterDropdown.appendChild(option);
        }

        // Collect all availability statuses
        const availabilitySet = new Set();
        ports.forEach(port => {
            if (port.availability) {
                availabilitySet.add(port.availability);
            }
        });
        const allAvailability = Array.from(availabilitySet).sort();

        // Populate availability dropdown
        for (const avail of allAvailability) {
            const option = document.createElement('option');
            option.value = avail;

            // Customize display text
            let displayText;
            switch (avail.toLowerCase()) {
                case 'full':
                    displayText = 'Ready to run';
                    break;
                case 'demo':
                    displayText = "Demo files included";
                case 'free':
                    displayText = 'Free, files needed';
                    break;
                default:
                    displayText = avail.charAt(0).toUpperCase() + avail.slice(1);
            }

            option.textContent = displayText;
            availabilityDropdown.appendChild(option);
        }

        // Sort function
        function sortPorts(list, method) {
            if (method === 'most_recent') {
                return list.slice().sort((a, b) => {
                    const dateA = new Date(a.last_modified || 0);
                    const dateB = new Date(b.last_modified || 0);
                    return dateB - dateA;
                });
            } else {
                return list.slice().sort((a, b) => a.title.localeCompare(b.title));
            }
        }

        // Render function
        function render(filteredPorts) {
            container.innerHTML = '';

            const genreVal = filterDropdown.value;
            const availabilityVal = availabilityDropdown.value;

            // Compose count display text
            let countText = `${filteredPorts.length} released ports`;
            if (genreVal !== 'all') {
                const genreText = filterDropdown.options[filterDropdown.selectedIndex].text;
                countText += ` in genre "${genreText}"`;
            }
            if (availabilityVal !== 'all') {
                const availText = availabilityDropdown.options[availabilityDropdown.selectedIndex].text;
                countText += ` with availability "${availText}"`;
            }

            countDisplay.textContent = countText;

            // Build port cards
            for (const port of filteredPorts) {
                const card = document.createElement('div');
                card.className = 'port-card';

                const img = document.createElement('img');
                img.src = port.screenshot_url;
                img.alt = `${port.title} screenshot`;
                card.appendChild(img);

                const info = document.createElement('div');
                info.className = 'port-info';

                const title = document.createElement('h2');
                title.className = 'port-title';
                title.textContent = port.title;
                info.appendChild(title);

                const desc = document.createElement('p');
                desc.className = 'port-desc';
                desc.textContent = port.description;
                info.appendChild(desc);

                const footer = document.createElement('div');
                footer.className = 'port-footer';

                if (port.genres?.length) {
                    const genres = document.createElement('div');
                    genres.className = 'port-genres';
                    genres.textContent = port.genres.join(', ');
                    footer.appendChild(genres);
                }

                const buttons = document.createElement('div');
                buttons.className = 'port-buttons';

                const details = document.createElement('a');
                details.className = 'details-link';
                details.href = port.download_url;
                details.target = '_blank';
                details.rel = 'noopener noreferrer';
                details.textContent = 'Details';

                const download = document.createElement('a');
                download.className = 'download-link';
                download.href = `https://downgit.github.io/#/home?url=${encodeURIComponent(port.download_url)}`;
                download.target = '_blank';
                download.rel = 'noopener noreferrer';
                download.textContent = 'Download';

                buttons.appendChild(details);
                buttons.appendChild(download);
                footer.appendChild(buttons);

                info.appendChild(footer);
                card.appendChild(info);
                container.appendChild(card);
            }
        }

        // Filter + sort + render
        function updateDisplay() {
            const selectedGenre = filterDropdown.value;
            const selectedAvailability = availabilityDropdown.value;

            let filtered = ports;

            if (selectedGenre !== 'all') {
                filtered = filtered.filter(port => port.genres?.includes(selectedGenre));
            }
            if (selectedAvailability !== 'all') {
                filtered = filtered.filter(port => port.availability === selectedAvailability);
            }

            const sortMethod = sortDropdown.value;
            filtered = sortPorts(filtered, sortMethod);

            render(filtered);
        }

        // Initial render
        updateDisplay();

        // Event listeners for all filters and sort
        filterDropdown.addEventListener('change', updateDisplay);
        availabilityDropdown.addEventListener('change', updateDisplay);
        sortDropdown.addEventListener('change', updateDisplay);

    } catch (err) {
        container.textContent = 'Error loading ports: ' + err.message;
    }
}

loadPorts();
