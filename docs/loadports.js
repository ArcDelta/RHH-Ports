async function loadPorts() {
    const container = document.getElementById('ports-container');
    const countDisplay = document.getElementById('port-count');
    const filterDropdown = document.getElementById('genre-filter');
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
            option.textContent = genre;
            filterDropdown.appendChild(option);
        }

        // Sort function
        function sortPorts(list, method) {
            if (method === 'most_recent') {
                return list.slice().sort((a, b) => {
                    // Safely parse dates, fallback to 0 if missing or invalid
                    const dateA = new Date(a.last_modified || 0);
                    const dateB = new Date(b.last_modified || 0);
                    return dateB - dateA;
                });
            } else {
                return list.slice().sort((a, b) => a.title.localeCompare(b.title));
            }
        }

        // Render cards
        function render(filteredPorts) {
            container.innerHTML = '';
            
            if (filterDropdown.value === 'all') {
                countDisplay.textContent = `${filteredPorts.length} released ports`;
            } else {
                const selectedGenre = filterDropdown.options[filterDropdown.selectedIndex].text;
                countDisplay.textContent = `${filteredPorts.length} released ports in genre "${selectedGenre}"`;
            }

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

        // Function to filter and sort then render
        function updateDisplay() {
            const selectedGenre = filterDropdown.value;
            let filtered = selectedGenre === 'all' ? ports : ports.filter(port => port.genres?.includes(selectedGenre));

            // Apply sorting
            const sortMethod = sortDropdown.value;
            filtered = sortPorts(filtered, sortMethod);

            render(filtered);
        }

        // Initial render
        updateDisplay();

        // Event listeners
        filterDropdown.addEventListener('change', updateDisplay);
        sortDropdown.addEventListener('change', updateDisplay);

    } catch (err) {
        container.textContent = 'Error loading ports: ' + err.message;
    }
}

loadPorts();