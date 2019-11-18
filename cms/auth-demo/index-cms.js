import { useCMS, useCMSForm } from 'react-tinacms'

export default function addCms(props) {
  let cms = useCMS()
  let [jumbo, form] = useCMSForm({
    id: props.fileRelativePath, // needs to be unique
    label: 'Edit Jumbo',

    initialValues: {
      title: props.title,
      lead: props.lead,
      leadtext: props.leadtext
    },

    fields: [
      {
        name: 'title',
        label: 'Title',
        component: 'text',
      },
      {
        name: 'lead',
        label: 'Lead',
        component: 'text',
      },
      {
        name: 'leadtext',
        label: 'Text',
        component: 'textarea',
      },
    ],

    // save & commit the file when the "save" button is pressed
    onSubmit(data) {
      return cms.api.git
        .writeToDisk({
          fileRelativePath: props.fileRelativePath,
          content: JSON.stringify({
            title: data.title,
            lead: data.lead,
            leadtext: data.leadtext,
          }, null, 2),
        })
      // .then(() => {
      //   return cms.api.git.commit({
      //     files: [props.fileRelativePath],
      //     message: `Commit from Tina: Update ${data.fileRelativePath}`,
      //   })
      // })
    },

    reset() {
      return cms.api.git.reset({ files: [props.fileRelativePath] })
    }
  })

  return jumbo
}
 