const fs = require('fs').promises;
const path = require('path');

const screenshotExtensions = ['.png', '.jpg'];

async function findPortsWithScreenshots(dir) {
    const ports = [];

    async function walk(currentDir) {
        const entries = await fs.readdir(currentDir, { withFileTypes: true });

        const hasPortJson = entries.some(e => e.isFile() && e.name.toLowerCase() === 'port.json');
        const screenshotFile = entries.find(
            e =>
            e.isFile() &&
            e.name.toLowerCase().startsWith('screenshot') &&
            screenshotExtensions.includes(path.extname(e.name).toLowerCase())
        );

        if (hasPortJson && screenshotFile) {
            ports.push({
                dir: currentDir,
                screenshotFile: screenshotFile.name,
            });
        }

        for (const entry of entries) {
            if (entry.isDirectory()) {
                await walk(path.join(currentDir, entry.name));
            }
        }
    }

    await walk(dir);
    return ports;
}

async function getLatestModifiedDate(dir) {
  let latestMtime = 0;

  async function walk(currentDir) {
    const entries = await fs.readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isFile()) {
        const stat = await fs.stat(fullPath);
        if (stat.mtimeMs > latestMtime) {
          latestMtime = stat.mtimeMs;
        }
      } else if (entry.isDirectory()) {
        await walk(fullPath);
      }
    }
  }

  await walk(dir);

  if (latestMtime === 0) return new Date().toISOString();

  return new Date(latestMtime).toISOString();
}

async function main() {
    const baseDir = path.resolve('./ports/released');
    const outputFile = path.resolve('./docs/ports.json');

    const portsFound = await findPortsWithScreenshots(baseDir);
    const ports = [];

    for (const { dir, screenshotFile } of portsFound) {
        try {
            const portJsonPath = path.join(dir, 'port.json');
            const portJsonRaw = await fs.readFile(portJsonPath, 'utf-8');
            const portData = JSON.parse(portJsonRaw);

            // Get latest modified date from all files in the port folder
            const lastModifiedDate = await getLatestModifiedDate(dir);

            const relativeDir = path.relative(baseDir, dir).replace(/\\/g, '/');

            ports.push({
                title: portData.attr?.title || path.basename(dir),
                description: portData.attr?.desc || '',
                download_url: `https://github.com/JeodC/RHH-Ports/tree/main/ports/released/${relativeDir}`,
                screenshot_url: `https://raw.githubusercontent.com/JeodC/RHH-Ports/main/ports/released/${relativeDir}/${screenshotFile}`,
                porter: portData.attr?.porter || [],
                genres: portData.attr?.genres || [],
                availability: portData.attr?.availability || 'unknown',
                store: portData.attr?.store || [],
                instructions: portData.attr?.inst || '',
                runtime: portData.attr?.runtime || [],
                exp: portData.attr?.exp || false,
                rtr: portData.attr?.rtr || false,
                arch: portData.attr?.arch || [],
                min_glibc: portData.attr?.min_glibc || '',
                last_modified: lastModifiedDate,
            });
        } catch (e) {
            console.warn(`Failed to process ${dir}:`, e.message);
        }
    }

    ports.sort((a, b) => a.title.toLowerCase().localeCompare(b.title.toLowerCase()));

    await fs.writeFile(outputFile, JSON.stringify(ports, null, 2), 'utf-8');
    console.log(`Generated ports.json with ${ports.length} ports.`);
}

main().catch(e => {
    console.error(e);
    process.exit(1);
});