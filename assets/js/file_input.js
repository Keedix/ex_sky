export const FileInput = {
    init: () => {
        const raportFile = window.document.getElementById("raport_file");
        const fileName = window.document.getElementById("file_name");

        // ************************ Drag and drop ***************** //
        let dropArea = document.getElementById("drop-area")
        console.log(dropArea)
            // Prevent default drag behaviors
            ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                dropArea.addEventListener(eventName, preventDefaults, false)
                document.body.addEventListener(eventName, preventDefaults, false)
            })

            // Highlight drop area when item is dragged over it
            ;['dragenter', 'dragover'].forEach(eventName => {
                dropArea.addEventListener(eventName, highlight, false)
            })

            ;['dragleave', 'drop'].forEach(eventName => {
                dropArea.addEventListener(eventName, unhighlight, false)
            })

        // Handle dropped files
        dropArea.addEventListener('drop', handleDrop, false)

        function preventDefaults(e) {
            e.preventDefault()
            e.stopPropagation()
        }

        function highlight(e) {
            dropArea.classList.add('highlight')
            dropArea.childNodes[1].classList.add('bg-gray-100');
        }

        function unhighlight(e) {
            dropArea.classList.remove('active')
            dropArea.childNodes[1].classList.remove('bg-gray-100');
        }

        function handleDrop(e) {
            console.log("tu", e.dataTransfer.files);
            // fileInput.files = e.dataTransfer.files;
            raportFile.files = e.dataTransfer.files;
            const splitted = raportFile.value.split('\\');
            const name = splitted[splitted.length - 1];
            fileName.innerHTML = name;
        }

    }
}