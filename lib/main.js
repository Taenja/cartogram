    // Controls
    const gui = new dat.GUI();

    const colorScale = d3.scaleSequential(d3.interpolateYlOrBr);

    const cartogram = Cartogram()
        .valFormatter(n => n.toPrecision(3))
        (document.getElementById('world'));

    d3.json('data/ne_110m_admin_0_countries.json', (error, world) => {
        if (error) throw error;

        // exclude antarctica
        world.objects.countries.geometries.splice(
            world.objects.countries.geometries.findIndex(d => d.properties.ISO_A2 === 'AQ'),
            1
        );

        let ccData;

        cartogram
            .topoJson(world)
            .topoObjectName('countries')
            .value(({ properties: { ISO_A2 } }) => ccData[ISO_A2])
            .color(({ properties: { ISO_A2 } }) => colorScale(ccData[ISO_A2]))
            .label(({ properties: p }) => `${p.NAME} (${p.ISO_A2})`)
            .onClick(d => console.info(d));
            

        const controls = { 'Iterations': 15, 'Randomize': () => { genVals(); render(); }};
        gui.add(controls, 'Iterations', 1, 40).step(1).onChange(render);
        gui.add(controls, 'Randomize');

        genVals();
        render();

        //

        function genVals() {
            ccData = Object.assign(...world.objects.countries.geometries
                .map(({ properties: { ISO_A2 } }) => ({ [ISO_A2]: Math.random() }))
            );
        }

        function render() {
            cartogram.iterations(controls.Iterations);
        }
    });

