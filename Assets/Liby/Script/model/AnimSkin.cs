 using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimSkin : MonoBehaviour
{
    public enum ModelSet
    {
        Mesh,
        Skin,
    }
    public ModelSet modelSet;
    int blendShapeCount;
    MeshFilter meshFilter;
    MeshRenderer meshRenderer;
    SkinnedMeshRenderer skinnedMeshRenderer;
    Mesh mesh;


    Texture2D texture;
    RenderTexture modelTexture;

    public GameObject objSkin;
    MeshFilter skinMesh;

    void Awake()
    {
        //非骨骼模型
        if (modelSet==ModelSet.Mesh){
            meshRenderer = GetComponent<MeshRenderer>();
            meshFilter=GetComponent<MeshFilter>();
            mesh=meshFilter.mesh;
            //顶点cpu
            originalVertices = mesh.vertices;
            displacedVertices = new Vector3[originalVertices.Length];
            for (int i = 0; i < originalVertices.Length; i++)
            {
                displacedVertices[i] = originalVertices[i];
            }
            lastVertices = new Vector3[originalVertices.Length];
            normals = mesh.normals;
            colors = mesh.colors;
        }
        //骨骼模型
        else if(modelSet==ModelSet.Skin){
            skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
            skinMesh = objSkin.GetComponent<MeshFilter>();
            meshRenderer = objSkin.GetComponent<MeshRenderer>();
            meshRenderer.materials = skinnedMeshRenderer.materials;
            //定义顶点数组
            mesh = skinnedMeshRenderer.sharedMesh;
            originalVertices = mesh.vertices;
            displacedVertices = new Vector3[originalVertices.Length];
            lastVertices = new Vector3[originalVertices.Length];
            colors = mesh.colors;
        }
        
        //顶点gpu
        modelTexture = new RenderTexture(256, 256, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
       

    }

    
    public float range;
    Vector3[] originalVertices, displacedVertices;
    Vector3[] lastVertices;
    Vector3[] normals;
    Color[] colors;

    void Start()
    {
        

    }
    private void Update() {
        
        SetMesh();
    }
    void SetMesh()
    {
        Debug.Log(colors.Length  );
        Debug.Log(originalVertices.Length);
  
        if (modelSet==ModelSet.Mesh){
            //Graphics.Blit();
            originalVertices = mesh.vertices;
            for(int i=0; i< originalVertices.Length; i++)
            {
                UpdateVertex(i);
            }
            mesh.vertices = displacedVertices;
            mesh.RecalculateNormals();
        }
        else if(modelSet==ModelSet.Skin){
            mesh = new Mesh();
            skinnedMeshRenderer.BakeMesh(mesh);
            skinMesh.mesh = mesh;
            originalVertices = mesh.vertices;
            normals = mesh.normals;
            //displacedVertices = new Vector3[mesh.vertices.Length];
            for (int i = 0; i < originalVertices.Length; i++)
            {
                UpdateSkin(i);
            }
           
            mesh.vertices = displacedVertices;
            mesh.RecalculateNormals();


            #region 使用顶点色存储循环次数过多造成卡顿
            // for (int i = 0; i < color.Length; i++)
            // {
            //     if(lastVex==null)break;
            //     color[i].r=lastVex[i].x-mesh.vertices[i].x;
            //     color[i].g=lastVex[i].y-mesh.vertices[i].y;
            //     color[i].b=lastVex[i].z-mesh.vertices[i].z;
            //     color[i].a=(lastVex[i]-mesh.vertices[i]).magnitude/range;
            // }

            // lastVex=mesh.vertices;

            //Debug.Log(lastVex[0]);
            #endregion
        }
        

    }
    void UpdateVertex(int i)
    {
        if (Vector3.Dot(lastVertices[i] - originalVertices[i], normals[i]) > 0)
        {
            displacedVertices[i] = (originalVertices[i] + lastVertices[i]) * 0.5f;
        }
        else
        {
            displacedVertices[i] = originalVertices[i];
        }
        lastVertices[i] = displacedVertices[i];
        //Vector3 velocity = vertexVelocities[i];
        //Vector3 displacement = displacedVertices[i] - originalVertices[i];
        //displacement *= uniformScale;
        //velocity -= displacement * springForce * Time.deltaTime;
        //velocity *= 1f - damping * Time.deltaTime;
        //vertexVelocities[i] = velocity;
        //displacedVertices[i] += velocity * (Time.deltaTime / uniformScale);
    }
    void UpdateSkin(int i)
    {
        if(Vector3.Dot(lastVertices[i] - originalVertices[i], normals[i]) > 0)
        {
            displacedVertices[i] = (originalVertices[i] + lastVertices[i]) * 0.5f;
        }
        else
        {
            displacedVertices[i] = originalVertices[i];
        }
        lastVertices[i] = displacedVertices[i];
      
    }
}
