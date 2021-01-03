    // Controls
    const gui = new dat.GUI();
    const colorScale = d3.scaleSequential(d3.interpolateReds)
                         .domain([0, 0.08]);

    const cartogram = Cartogram()
        .valFormatter(n => n.toPrecision(3))
        (document.getElementById('world'));

    d3.json('data/sen_slope.json', (error, world) => {
        if (error) throw error;

        // exclude antarctica
        world.objects.ne_110m_admin_0_countries2.geometries.splice(
            world.objects.ne_110m_admin_0_countries2.geometries.findIndex(d => d.properties.ISO_A2 === 'AQ'),
            1
        );

        cartogram
            .topoJson(world)
            .topoObjectName('ne_110m_admin_0_countries2')
            .value(getSlope)
            .color(f => colorScale(getSlope(f)))
            .label(({ properties: p }) => `${p.NAME}`)
            .onClick(d => console.info(d));
            

        const controls = { 'Iterations': 5};
        gui.add(controls, 'Iterations', 1, 15).step(1).onChange(render);
        render();

        //

        function getSlope({ properties: p }) {
            return p.sen_slope;
        }

        function render() {
            cartogram.iterations(controls.Iterations);
        }
    });

