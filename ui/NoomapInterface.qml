import QtQuick 2.4

Rectangle {
    id: noomap_interface
    color: 'black'

    property var holarchy
    property var root_holon
    property var focussed_holon

    property var current_holons: []

    Component.onCompleted: {
        holarchy.loaded.connect(holarchyUpdate)
    }

    function holarchyUpdate() {
        noomap_interface.root_holon = holarchy.root_id
        noomap_interface.focussed_holon = holarchy.root_id
        createHolonDelegates()
    }

    function createHolonDelegates() {
        var children = holarchy.getChildren( noomap_interface.focussed_holon )


        var color_from_type = function(type) {
            switch(type){
            case 'v': return 'blue';
            case 'i': return 'yellow';
            case 's': return 'orange';
            case 'p': return 'green';
            }
        }

        var component = Qt.createComponent("Holon.qml");
        while(component.status !== Component.Ready) ;

        clearHolons();

        for(var i=0; i < children.length; i++){
            var holon = children[i];
            var delegate = component.createObject(noomap_interface, {
              'color': color_from_type( holon._t ),
              'source': holon
            });
            current_holons.push( delegate );
        }
    }

    function clearHolons() {
        for(var i=0; i < current_holons.length; i++){
            current_holons[i].destroy();
        }
        current_holons = []
    }

}
